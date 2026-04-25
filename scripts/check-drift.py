#!/usr/bin/env python3
"""
Image and Helm chart drift checker for the home-lab cluster.

Source of truth is the live cluster: discovers running images and Helm
releases via kubectl/helm, classifies each image by how it's managed
(helm-managed, standalone, floating-tag, k3s/chart-bundled), then
queries upstream registries and chart repos to report drift.

Usage:
    scripts/check-drift.py              # full report
    scripts/check-drift.py --no-cache   # skip cache, force fresh fetch
    scripts/check-drift.py --json       # machine-readable output

Requires: kubectl, helm, python3 (stdlib only).
"""

from __future__ import annotations

import argparse
import json
import os
import re
import subprocess
import sys
import time
import urllib.error
import urllib.request
from concurrent.futures import ThreadPoolExecutor
from dataclasses import dataclass, field
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

CACHE_DIR = Path("/tmp/check-drift-cache")
CACHE_TTL_SECONDS = 3600
HTTP_TIMEOUT = 15


# ---------------------------------------------------------------------------
# Shell helpers
# ---------------------------------------------------------------------------

def run(cmd: list[str], check: bool = True) -> str:
    """Run a command and return stdout, raising if it fails."""
    res = subprocess.run(cmd, capture_output=True, text=True)
    if check and res.returncode != 0:
        raise RuntimeError(f"{' '.join(cmd)} failed: {res.stderr.strip()}")
    return res.stdout


# ---------------------------------------------------------------------------
# Cache
# ---------------------------------------------------------------------------

def cache_get(key: str) -> Any | None:
    if not CACHE_DIR.exists():
        return None
    path = CACHE_DIR / (re.sub(r"[^A-Za-z0-9._-]", "_", key) + ".json")
    if not path.exists():
        return None
    if time.time() - path.stat().st_mtime > CACHE_TTL_SECONDS:
        return None
    try:
        return json.loads(path.read_text())
    except Exception:
        return None


def cache_put(key: str, value: Any) -> None:
    CACHE_DIR.mkdir(parents=True, exist_ok=True)
    path = CACHE_DIR / (re.sub(r"[^A-Za-z0-9._-]", "_", key) + ".json")
    path.write_text(json.dumps(value))


# ---------------------------------------------------------------------------
# Cluster discovery
# ---------------------------------------------------------------------------

@dataclass
class RunningImage:
    """One unique image:tag observed running in the cluster."""
    image: str        # "docker.io/library/redis:alpine"
    digest: str       # "sha256:..."
    pods: list[str] = field(default_factory=list)  # ["ns/pod"]
    helm_release: str | None = None  # "ns/release-name" if managed by helm

    @property
    def registry(self) -> str:
        first = self.image.split("/", 1)[0]
        return first if "." in first else "docker.io"

    @property
    def repo(self) -> str:
        rest = self.image if self.registry != "docker.io" or self.image.startswith("docker.io/") else f"docker.io/{self.image}"
        rest = rest.split(":", 1)[0]
        rest = rest[len(self.registry) + 1:]
        if self.registry == "docker.io" and "/" not in rest:
            rest = f"library/{rest}"
        return rest

    @property
    def tag(self) -> str:
        return self.image.split(":")[-1] if ":" in self.image else "latest"


@dataclass
class HelmRelease:
    namespace: str
    name: str
    chart_name: str        # "forgejo"
    chart_version: str     # "13.0.1"
    app_version: str       # "12.0.1"
    repo_url: str | None   # "https://charts.kubito.dev" or None for OCI


def discover_pods() -> list[RunningImage]:
    """Return one RunningImage per (image, digest) tuple, with pod refs."""
    raw = json.loads(run(["kubectl", "get", "pods", "-A", "-o", "json"]))
    by_key: dict[tuple[str, str], RunningImage] = {}
    for pod in raw["items"]:
        if pod.get("status", {}).get("phase") != "Running":
            continue
        ns = pod["metadata"]["namespace"]
        name = pod["metadata"]["name"]
        for cs in pod.get("status", {}).get("containerStatuses", []) or []:
            image = cs.get("image", "")
            image_id = cs.get("imageID", "")
            digest = ""
            if "@sha256:" in image_id:
                digest = image_id.split("@", 1)[1]
            key = (image, digest)
            if key not in by_key:
                by_key[key] = RunningImage(image=image, digest=digest)
            by_key[key].pods.append(f"{ns}/{name}")
    return list(by_key.values())


def discover_helm_releases() -> list[HelmRelease]:
    raw = json.loads(run(["helm", "list", "-A", "-o", "json"]))
    out = []
    for r in raw:
        chart = r["chart"]  # e.g. "forgejo-13.0.1"
        m = re.match(r"^(.*)-([0-9][^-]*(?:-[a-zA-Z0-9.+]+)?)$", chart)
        if m:
            chart_name, chart_version = m.group(1), m.group(2)
        else:
            chart_name, chart_version = chart, ""
        # Get repo URL via helm get metadata
        repo_url = None
        try:
            md = json.loads(run([
                "helm", "get", "metadata", r["name"],
                "-n", r["namespace"], "-o", "json"
            ], check=False))
            repo_url = md.get("annotations", {}).get("home") or None
            # The metadata "chart" has the chart name; we need a config-stored URL.
            # helm doesn't store the repo URL by default; fall back to known mappings.
        except Exception:
            pass
        out.append(HelmRelease(
            namespace=r["namespace"],
            name=r["name"],
            chart_name=chart_name,
            chart_version=chart_version,
            app_version=r.get("app_version", ""),
            repo_url=repo_url,
        ))
    return out


def annotate_pods_with_helm(pods: list[RunningImage]) -> None:
    """Tag each RunningImage with helm_release via owner-chain lookup."""
    # Build a map of (ns, owner-uid) -> helm_release using deployments/statefulsets/daemonsets
    raw = json.loads(run(["kubectl", "get", "deploy,sts,ds,job,cronjob",
                          "-A", "-o", "json"]))
    owner_to_release: dict[str, str] = {}  # uid -> "ns/release"
    for item in raw["items"]:
        ann = item["metadata"].get("annotations", {}) or {}
        rel = ann.get("meta.helm.sh/release-name")
        rel_ns = ann.get("meta.helm.sh/release-namespace") or item["metadata"]["namespace"]
        if rel:
            owner_to_release[item["metadata"]["uid"]] = f"{rel_ns}/{rel}"

    # For each pod, look at ownerReferences -> ReplicaSet -> Deployment, etc.
    # Simpler heuristic: re-fetch all pods and their ownerRefs, walk one level
    # to ReplicaSets, then their owner is the Deployment we already mapped.
    rs_raw = json.loads(run(["kubectl", "get", "rs", "-A", "-o", "json"]))
    rs_to_deploy: dict[str, str] = {}  # rs uid -> deploy uid
    for rs in rs_raw["items"]:
        for owner in rs["metadata"].get("ownerReferences", []) or []:
            if owner["kind"] == "Deployment":
                rs_to_deploy[rs["metadata"]["uid"]] = owner["uid"]

    pod_raw = json.loads(run(["kubectl", "get", "pods", "-A", "-o", "json"]))
    pod_release: dict[str, str] = {}  # "ns/pod" -> "ns/release"
    for pod in pod_raw["items"]:
        ns = pod["metadata"]["namespace"]
        name = pod["metadata"]["name"]
        for owner in pod["metadata"].get("ownerReferences", []) or []:
            uid = owner["uid"]
            if owner["kind"] == "ReplicaSet":
                uid = rs_to_deploy.get(uid, uid)
            if uid in owner_to_release:
                pod_release[f"{ns}/{name}"] = owner_to_release[uid]
                break

    for img in pods:
        for pod_ref in img.pods:
            if pod_ref in pod_release:
                img.helm_release = pod_release[pod_ref]
                break


# ---------------------------------------------------------------------------
# Registry queries
# ---------------------------------------------------------------------------

def http_get_json(url: str, headers: dict[str, str] | None = None) -> Any:
    req = urllib.request.Request(url, headers=headers or {})
    with urllib.request.urlopen(req, timeout=HTTP_TIMEOUT) as r:
        return json.load(r)


def fetch_oci_token(www_authenticate: str) -> str | None:
    """Parse a 401 Bearer challenge and fetch an anonymous token."""
    m = re.search(r'realm="([^"]+)"', www_authenticate)
    if not m:
        return None
    realm = m.group(1)
    service = re.search(r'service="([^"]+)"', www_authenticate)
    scope = re.search(r'scope="([^"]+)"', www_authenticate)
    params = []
    if service: params.append(f"service={service.group(1)}")
    if scope: params.append(f"scope={scope.group(1)}")
    url = realm + ("?" + "&".join(params) if params else "")
    try:
        data = http_get_json(url)
        return data.get("token") or data.get("access_token")
    except Exception:
        return None


def list_tags(registry: str, repo: str) -> list[str]:
    """Return all tags for a registry/repo, anonymously."""
    cache_key = f"tags::{registry}::{repo}"
    cached = cache_get(cache_key)
    if cached is not None:
        return cached

    if registry == "docker.io":
        # Docker Hub has a separate API.
        url = f"https://hub.docker.com/v2/repositories/{repo}/tags?page_size=100&ordering=last_updated"
        tags: list[str] = []
        while url and len(tags) < 500:
            try:
                data = http_get_json(url)
                tags.extend(t["name"] for t in data.get("results", []))
                url = data.get("next")
            except Exception:
                break
        cache_put(cache_key, tags)
        return tags

    # OCI v2 API
    url = f"https://{registry}/v2/{repo}/tags/list"
    try:
        data = http_get_json(url)
        tags = data.get("tags") or []
    except urllib.error.HTTPError as e:
        if e.code == 401:
            token = fetch_oci_token(e.headers.get("WWW-Authenticate", ""))
            if token:
                try:
                    data = http_get_json(url, {"Authorization": f"Bearer {token}"})
                    tags = data.get("tags") or []
                except Exception:
                    tags = []
            else:
                tags = []
        else:
            tags = []
    except Exception:
        tags = []

    cache_put(cache_key, tags)
    return tags


SEMVER_RE = re.compile(r"^v?(\d+)\.(\d+)\.(\d+)(?:[.\-+]([\w\.\-]+))?$")
PRE_MARKERS = ("rc", "alpha", "beta", "dev", "snapshot", "pre")


def parse_semver(tag: str) -> tuple[int, int, int, bool, str] | None:
    m = SEMVER_RE.match(tag)
    if not m:
        return None
    major, minor, patch, suffix = m.groups()
    is_pre = bool(suffix and any(p in suffix.lower() for p in PRE_MARKERS))
    return (int(major), int(minor), int(patch), is_pre, suffix or "")


def newest_compatible(current: str, tags: list[str]) -> str | None:
    """Find the newest semver tag with the same shape as current.
    Returns None if current is already newest (or current isn't semver)."""
    cur = parse_semver(current)
    if cur is None:
        return None
    cmaj, cmin, cpatch, cpre, csuffix = cur
    suffix_family = re.sub(r"\d+$", "", csuffix) if csuffix else ""

    best = cur
    for t in tags:
        p = parse_semver(t)
        if p is None:
            continue
        pmaj, pmin, ppatch, ppre, psuf = p
        if suffix_family:
            psuf_family = re.sub(r"\d+$", "", psuf) if psuf else ""
            if psuf_family != suffix_family:
                continue
        if cpre != ppre:
            continue
        if (pmaj, pmin, ppatch) > (best[0], best[1], best[2]):
            best = p

    if (best[0], best[1], best[2]) == (cur[0], cur[1], cur[2]):
        return None
    prefix = "v" if current.startswith("v") else ""
    suffix = "-" + best[4] if best[4] else ""
    return f"{prefix}{best[0]}.{best[1]}.{best[2]}{suffix}"


def fetch_amd64_digest(image_with_tag: str) -> str | None:
    """Resolve a tag to its linux/amd64 manifest digest via docker buildx."""
    cache_key = f"digest::{image_with_tag}"
    cached = cache_get(cache_key)
    if cached is not None:
        return cached
    try:
        raw = subprocess.run(
            ["docker", "buildx", "imagetools", "inspect", image_with_tag, "--raw"],
            capture_output=True, text=True, timeout=30,
        )
        if raw.returncode != 0:
            return None
        data = json.loads(raw.stdout)
        if "manifests" in data:
            for m in data["manifests"]:
                p = m.get("platform", {})
                if p.get("architecture") == "amd64" and p.get("os") == "linux":
                    cache_put(cache_key, m["digest"])
                    return m["digest"]
        # Single-arch image: the manifest itself is the platform manifest.
        # Get the descriptor digest.
        desc_raw = subprocess.run(
            ["docker", "buildx", "imagetools", "inspect", image_with_tag,
             "--format", "{{.Manifest.Digest}}"],
            capture_output=True, text=True, timeout=15,
        )
        if desc_raw.returncode == 0:
            d = desc_raw.stdout.strip()
            cache_put(cache_key, d)
            return d
    except Exception:
        pass
    return None


def fetch_image_created(image_ref: str) -> str | None:
    """Get the upstream image's `created` ISO timestamp (linux/amd64)."""
    cache_key = f"created::{image_ref}"
    cached = cache_get(cache_key)
    if cached is not None:
        return cached
    try:
        raw = subprocess.run(
            ["docker", "buildx", "imagetools", "inspect", image_ref,
             "--format", "{{json .Image}}"],
            capture_output=True, text=True, timeout=30,
        )
        if raw.returncode != 0:
            return None
        data = json.loads(raw.stdout)
        ts = (data.get("linux/amd64") or {}).get("created") or data.get("created")
        cache_put(cache_key, ts)
        return ts
    except Exception:
        return None


# ---------------------------------------------------------------------------
# Helm chart latest-version lookup
# ---------------------------------------------------------------------------

# Known repo URLs for our helm releases (helm doesn't store repo URLs in state).
# This is the only fallback; the script otherwise discovers everything from
# the cluster.
KNOWN_CHART_REPOS = {
    "forgejo":              "oci://code.forgejo.org/forgejo-helm",
    "grafana":              "https://grafana.github.io/helm-charts",
    "alloy":                "https://grafana.github.io/helm-charts",
    "loki":                 "https://grafana.github.io/helm-charts",
    "pyroscope":            "https://grafana.github.io/helm-charts",
    "tempo":                "https://grafana.github.io/helm-charts",
    "prometheus":           "https://prometheus-community.github.io/helm-charts",
    "n8n":                  "https://community-charts.github.io/helm-charts",
    "searxng":              "https://charts.kubito.dev",
    "kubernetes-dashboard": "https://kubernetes.github.io/dashboard/",
    "metallb":              "https://metallb.github.io/metallb",
    "democratic-csi":       "https://democratic-csi.github.io/charts/",
    "longhorn":             "https://charts.longhorn.io",
}


def fetch_latest_chart(chart_name: str) -> str | None:
    repo = KNOWN_CHART_REPOS.get(chart_name)
    if not repo:
        return None
    cache_key = f"chart::{chart_name}::{repo}"
    cached = cache_get(cache_key)
    if cached is not None:
        return cached

    if repo.startswith("oci://"):
        # `helm show chart` prints YAML; grep version
        try:
            out = subprocess.run(
                ["helm", "show", "chart", f"{repo}/{chart_name}"],
                capture_output=True, text=True, timeout=30,
            )
            for line in out.stdout.splitlines():
                if line.startswith("version:"):
                    v = line.split(":", 1)[1].strip()
                    cache_put(cache_key, v)
                    return v
        except Exception:
            return None
        return None

    # HTTP repo: fetch index.yaml and find chart entry's first (newest) version
    try:
        with urllib.request.urlopen(repo.rstrip("/") + "/index.yaml",
                                    timeout=HTTP_TIMEOUT) as r:
            text = r.read().decode("utf-8", errors="replace")
    except Exception:
        return None

    # Naive YAML scan (avoids external deps). Helm index.yaml shape:
    #
    #   entries:
    #     <chart_name>:
    #     - apiVersion: v2
    #       version: 1.2.3
    #       ...
    #     - version: 1.2.2
    #     <other-chart>:
    #
    # Enter the block on "  <chart_name>:"; exit when we hit another
    # top-level chart entry (line matching r'^  [a-zA-Z0-9_-]+:$').
    in_block = False
    next_chart_re = re.compile(r"^  [a-zA-Z0-9_-]+:\s*$")
    # Only the chart's *own* version is at 4-space indent (a top-level field
    # of the chart entry). Dependency versions are at 6+ spaces and must be
    # ignored.
    own_version_re = re.compile(r"^    version:\s*(.+)$")
    versions: list[str] = []
    for line in text.splitlines():
        if line.rstrip() == f"  {chart_name}:":
            in_block = True
            continue
        if in_block:
            if next_chart_re.match(line) and line.rstrip() != f"  {chart_name}:":
                break
            m = own_version_re.match(line)
            if m:
                versions.append(m.group(1).strip().strip('"'))

    if not versions:
        return None

    # Pick newest semver
    best = None
    best_parsed = None
    for v in versions:
        p = parse_semver(v)
        if p is None or p[3]:  # skip pre-releases
            continue
        if best_parsed is None or (p[0], p[1], p[2]) > (best_parsed[0], best_parsed[1], best_parsed[2]):
            best, best_parsed = v, p

    cache_put(cache_key, best)
    return best


# ---------------------------------------------------------------------------
# Reporting
# ---------------------------------------------------------------------------

def parse_iso(s: str | None) -> datetime | None:
    if not s:
        return None
    try:
        return datetime.fromisoformat(s.replace("Z", "+00:00"))
    except Exception:
        return None


def is_floating(tag: str) -> bool:
    """A tag is 'floating' if it doesn't pin a semver."""
    if tag in ("latest", "main", "master", "edge"):
        return True
    if parse_semver(tag) is None:
        # Things like "alpine", "stable-alpine-slim", "3.8" (only major.minor)
        return True
    return False


def short_image(image: str) -> str:
    return (image.replace("docker.io/library/", "")
                  .replace("docker.io/", "")
                  .split("@")[0])


def categorize(images: list[RunningImage]) -> dict[str, list[RunningImage]]:
    cats: dict[str, list[RunningImage]] = {
        "helm-managed": [],
        "standalone-pinned": [],
        "standalone-floating": [],
    }
    for img in images:
        if img.helm_release:
            cats["helm-managed"].append(img)
        elif is_floating(img.tag):
            cats["standalone-floating"].append(img)
        else:
            cats["standalone-pinned"].append(img)
    return cats


def report_helm(releases: list[HelmRelease]) -> list[dict[str, str]]:
    """Check each helm release for a newer chart version."""
    rows: list[dict[str, str]] = []

    def check(rel: HelmRelease) -> dict[str, str]:
        latest = fetch_latest_chart(rel.chart_name)
        status = "?"
        if latest is None:
            status = "unknown-repo"
        else:
            cur_p = parse_semver(rel.chart_version)
            new_p = parse_semver(latest)
            if cur_p and new_p:
                if (new_p[0], new_p[1], new_p[2]) > (cur_p[0], cur_p[1], cur_p[2]):
                    status = "BEHIND"
                else:
                    status = "up-to-date"
            else:
                status = "up-to-date" if rel.chart_version == latest else "BEHIND"
        return {
            "release": f"{rel.namespace}/{rel.name}",
            "chart": rel.chart_name,
            "current": rel.chart_version,
            "latest": latest or "?",
            "app_version": rel.app_version,
            "status": status,
        }

    with ThreadPoolExecutor(max_workers=6) as ex:
        rows = list(ex.map(check, releases))
    return rows


def report_pinned(images: list[RunningImage]) -> list[dict[str, str]]:
    def check(img: RunningImage) -> dict[str, str]:
        tags = list_tags(img.registry, img.repo)
        latest = newest_compatible(img.tag, tags) if tags else None
        if not tags:
            status = "no-tags-fetched"
        elif latest is None:
            status = "up-to-date"
        else:
            status = "BEHIND"
        return {
            "image": short_image(img.image),
            "current": img.tag,
            "latest": latest or img.tag,
            "status": status,
        }

    with ThreadPoolExecutor(max_workers=8) as ex:
        return list(ex.map(check, images))


def report_floating(images: list[RunningImage]) -> list[dict[str, str]]:
    def check(img: RunningImage) -> dict[str, str]:
        # Strategy:
        #   1. Compare amd64 manifest digests (cheap, definitive).
        #   2. If digests differ, fetch upstream image's `created` timestamp
        #      to estimate drift in days.
        upstream_digest = fetch_amd64_digest(img.image)
        status = "unknown"
        drift_days = ""
        running_built = "?"
        upstream_built = "?"

        if upstream_digest and img.digest and upstream_digest == img.digest:
            status = "up-to-date"
        elif upstream_digest and img.digest:
            # Digests differ. Could be a real drift, or just signed-vs-unsigned
            # manifest digest variance. Fall back to created-timestamp compare.
            ud = parse_iso(fetch_image_created(img.image))
            rd = parse_iso(fetch_image_created(
                f"{img.registry}/{img.repo}@{img.digest}"
            )) if img.digest else None
            if rd: running_built = rd.strftime("%Y-%m-%d")
            if ud: upstream_built = ud.strftime("%Y-%m-%d")
            if rd and ud:
                delta_days = (ud - rd).days
                if delta_days <= 0:
                    status = "up-to-date"
                else:
                    status = "BEHIND"
                    drift_days = f"{delta_days}d"
            else:
                status = "BEHIND"  # digests differ; can't quantify

        return {
            "image": short_image(img.image),
            "tag": img.tag,
            "running_built": running_built,
            "upstream_built": upstream_built,
            "drift": drift_days,
            "status": status,
        }

    with ThreadPoolExecutor(max_workers=4) as ex:
        return list(ex.map(check, images))


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def render_table(rows: list[dict[str, str]], cols: list[tuple[str, str]]) -> str:
    """rows = list of dicts; cols = list of (header, key) pairs."""
    if not rows:
        return "  (none)\n"
    headers = [h for h, _ in cols]
    keys = [k for _, k in cols]
    widths = [len(h) for h in headers]
    for r in rows:
        for i, k in enumerate(keys):
            widths[i] = max(widths[i], len(str(r.get(k, ""))))
    out = []
    out.append("  " + "  ".join(h.ljust(w) for h, w in zip(headers, widths)))
    out.append("  " + "  ".join("-" * w for w in widths))
    for r in rows:
        out.append("  " + "  ".join(str(r.get(k, "")).ljust(w)
                                    for k, w in zip(keys, widths)))
    return "\n".join(out) + "\n"


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--no-cache", action="store_true",
                        help="ignore cache; re-query everything")
    parser.add_argument("--json", action="store_true",
                        help="emit machine-readable JSON instead of a report")
    args = parser.parse_args()

    if args.no_cache and CACHE_DIR.exists():
        for f in CACHE_DIR.iterdir():
            f.unlink()

    print("Discovering cluster state...", file=sys.stderr)
    images = discover_pods()
    annotate_pods_with_helm(images)
    releases = discover_helm_releases()
    print(f"  {len(images)} unique running images, "
          f"{len(releases)} helm releases", file=sys.stderr)

    cats = categorize(images)

    print("Checking helm releases for chart drift...", file=sys.stderr)
    helm_rows = report_helm(releases)
    print("Checking pinned standalone images...", file=sys.stderr)
    pinned_rows = report_pinned(cats["standalone-pinned"])
    print("Checking floating-tag images for digest drift...", file=sys.stderr)
    floating_rows = report_floating(cats["standalone-floating"])

    if args.json:
        print(json.dumps({
            "helm": helm_rows,
            "standalone_pinned": pinned_rows,
            "standalone_floating": floating_rows,
            "helm_managed_images": [
                {"image": short_image(i.image), "tag": i.tag, "release": i.helm_release}
                for i in cats["helm-managed"]
            ],
        }, indent=2))
        return 0

    print()
    print("=" * 78)
    print("HELM RELEASES (bump chart version to update; image follows)")
    print("=" * 78)
    helm_rows_sorted = sorted(helm_rows, key=lambda r: (r["status"] != "BEHIND", r["release"]))
    print(render_table(helm_rows_sorted, [
        ("RELEASE", "release"),
        ("CHART", "chart"),
        ("NOW", "current"),
        ("LATEST", "latest"),
        ("APP", "app_version"),
        ("STATUS", "status"),
    ]))

    print("=" * 78)
    print("STANDALONE IMAGES — PINNED TAG (bump tag in versions.tf)")
    print("=" * 78)
    pinned_sorted = sorted(pinned_rows, key=lambda r: (r["status"] != "BEHIND", r["image"]))
    print(render_table(pinned_sorted, [
        ("IMAGE", "image"),
        ("CURRENT", "current"),
        ("LATEST", "latest"),
        ("STATUS", "status"),
    ]))

    print("=" * 78)
    print("STANDALONE IMAGES — FLOATING TAG (digest drift; restart pod or pin)")
    print("=" * 78)
    floating_sorted = sorted(floating_rows, key=lambda r: (r["status"] != "BEHIND", r["image"]))
    print(render_table(floating_sorted, [
        ("IMAGE", "image"),
        ("TAG", "tag"),
        ("RUNNING", "running_built"),
        ("UPSTREAM", "upstream_built"),
        ("DRIFT", "drift"),
        ("STATUS", "status"),
    ]))

    print("=" * 78)
    print("HELM-MANAGED IMAGES (drift resolves when parent chart bumps)")
    print("=" * 78)
    for img in sorted(cats["helm-managed"], key=lambda i: i.helm_release or ""):
        print(f"  {short_image(img.image):<60} via {img.helm_release}")
    print()

    behind = sum(1 for r in helm_rows + pinned_rows + floating_rows
                 if r.get("status") == "BEHIND")
    total = len(helm_rows) + len(pinned_rows) + len(floating_rows)
    print(f"Summary: {behind}/{total} entries behind")
    return 0


if __name__ == "__main__":
    sys.exit(main())
