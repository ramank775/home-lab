# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository purpose

Infrastructure-as-code for a personal home lab: k3s cluster (Pi 4 nodes + Proxmox-hosted x86 VMs), TrueNAS SCALE storage, OPNsense firewall, and the workloads that run on top. Everything is provisioned with Terraform + Ansible — avoid kubectl/helm-by-hand changes against the live cluster.

(Note: `README.md` is historical pre-Terraform/pre-Ansible manual setup notes — ignore it for current procedures.)

## The IaC trees

There are **six** Terraform roots plus one Ansible tree. Each root has its own `provider.tf`/`versions.tf`/`variables.tf`/`main.tf` and its own state. Per-environment values live in `.lab/<tree>/values.tfvars` (gitignored).

**Cluster build path** — apply in this order for a fresh build:

1. `setup/proxmox/` — Proxmox VMs (k3s nodes + Debian cloud-init template). State: cluster secret `setup-proxmox-state`. Needs `PROXMOX_VE_*` creds.
2. `setup/ansible/` — installs k3s on already-running nodes (Pis or the VMs from step 1). Entrypoint `setup.yml`; roles under `roles/{raspberrypi,k3s/{download,master,node},resources}`. Sample inventory: `inventories/sample/hosts.ini`.
3. `setup/k3s/` — cluster infra: metallb, traefik, democratic-csi (TrueNAS backend), system-upgrade-controller. State: `setup-state`.
4. `deployment/` — apps + shared services. **Mixed-provider** root: k8s Helm charts AND Proxmox LXCs/VMs that back the apps (databases, gateways, dev box, media stack). State: `deployment-state`. Needs both k8s and Proxmox creds.

**Independent infra trees** — applied separately, not part of the cluster boot order:

5. `network/opnsense/` — OPNsense firewall (rules, aliases, NAT, DHCP reservations, Unbound, WireGuard) via the `browningluke/opnsense` provider. **Local backend** at `.lab/network/opnsense/terraform.tfstate`. Requires the `os-api` plugin installed on OPNsense.
6. `storage/truenas/` — TrueNAS SCALE datasets, NFS/SMB shares, snapshot tasks, users via the `PjSalty/truenas` provider. **Local backend** at `.lab/storage/truenas/terraform.tfstate`. Provider does NOT manage TrueNAS apps/charts, pools, or network config — use the UI for those.

Cross-tree:
- `tf-modules/{proxmox-vm,proxmox-lxc}` — shared Terraform modules consumed by every tree that creates Proxmox resources.
- `system/upgrade/plan.yaml` — Rancher `system-upgrade-controller` plan (server + agent) tracking k3s `stable` channel.

## Workload code (built into images, consumed by `deployment/`)

- `apps/dovecot/` — custom Dovecot image. Built by `.github/workflows/dovecot.yaml` on push to `apps/dovecot/**`; pushed to `ramank775/dovecot:<version>` for `linux/amd64,linux/arm64`. Version is hardcoded in the workflow, not derived from the Dockerfile.
- `apps/nats-streaming-http-producer/` — Node service exposing HTTP → NATS publish.
- `apps/slack-notifier/` — Node consumer that posts NATS messages to Slack.
- `apps/tunnel-client/` — outbound tunnel client (`startup.sh` + config).
- `crons/blog-feature-posts/` — Python cron: top blogs → featured posts on blog.one9x.org.
- `crons/public-ip-monitor/` — shell cron: detect public-IP changes, publish to NATS.

## Commands

Terraform — always pass `-chdir` and the per-tree `-var-file`. State for the four cluster trees lives in cluster secrets, not local files; the two independent infra trees use local state under `.lab/`.

```sh
# Cluster build order
terraform -chdir=setup/proxmox apply -var-file=$PWD/.lab/setup/proxmox/values.tfvars
ansible-playbook -i setup/ansible/inventories/sample/hosts.ini setup/ansible/setup.yml
terraform -chdir=setup/k3s    apply -var-file=$PWD/.lab/setup/k3s/values.tfvars
terraform -chdir=deployment   apply -var-file=$PWD/.lab/deployment/values.tfvars

# Independent infra
terraform -chdir=network/opnsense apply -var-file=$PWD/.lab/network/opnsense/values.tfvars
terraform -chdir=storage/truenas  apply -var-file=$PWD/.lab/storage/truenas/values.tfvars
```

For `setup/proxmox/` and `deployment/`: export `PROXMOX_VE_ENDPOINT`, `PROXMOX_VE_API_TOKEN`, and have an SSH agent loaded with access to the Proxmox host (provider uses `ssh { agent = true }`).

Drift check — read-only, hits the live cluster, compares running images/charts against pinned versions:

```sh
scripts/check-drift.py            # full report
scripts/check-drift.py --no-cache # force fresh fetch
scripts/check-drift.py --json     # machine-readable
```

OPNsense bootstrap (one-time, see `network/opnsense/README.md` for full flow): run `network/opnsense/scripts/generate-imports.sh` to materialize `imports.tf` from live state, then `terraform plan -generate-config-out=generated.tf`, refactor into group subdirs, and verify zero destroys/replaces before applying.

CI: `.github/workflows/` only contains image-build pipelines (`dovecot.yaml`) and a smoke job for the Forgejo runner (`smoke.yaml`). **There is no Terraform CI** — applies are run by hand from the workstation.

## Version pinning

`deployment/versions.tf` is the single source of truth for image tags and Helm chart versions used in the `deployment/` tree (`local.versions.{charts,images}`). Make bumps there, not inline in module calls. Pins exist for compatibility reasons (e.g. Redis `8-alpine` — RDB v13 is forward-only). The `helm` provider is pinned to `~> 2.0` across every tree because all `provider.tf` files use v2 `kubernetes { ... }` block syntax — `init -upgrade` blindly will break things.

## Conventions worth knowing

- **Consistency over brevity.** Every Terraform root uses the same group-subdir layout (`<root>/<group>/<resource>/`), even when a tree only has one or two resources. Don't flatten — cross-tree consistency is valued over per-tree line count.
- **Per-host/per-system isolation for infra trees.** Each network device or storage system gets its own sibling directory (`network/<host>/`, `storage/<system>/`) with its own state, not a provider alias. Keeps blast radius small.
- **State migrations:** prefer Terraform `import {}` blocks over `terraform state mv` so drift is verified for free.
- **ARM64 quirks:** Pi nodes (pi-2, pi-3) are Cortex-A72, no ARMv8.1 LSE. Pin perf-sensitive workloads (Redis, etc.) to amd64 via `nodeSelector`. The k3s VMs created in `setup/proxmox/vms/` are amd64.
- **cloud-init gotcha:** don't add a user to a not-yet-installed group via `users[].groups` — `cc_users_groups` will fail and abort init (breaks DHCP). Use `usermod` in `runcmd:` instead.
- **kubeconfig:** `backend.local.hcl` files point Terraform at `~/.kube/config`; tfvars override with `kube_config` when needed.
- **`.lab/` is gitignored** and mirrors the source tree (e.g. `.lab/setup/proxmox/`, `.lab/network/opnsense/`). Local state for trees with `backend "local"` also lands here.
