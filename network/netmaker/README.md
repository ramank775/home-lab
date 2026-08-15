# network/netmaker

**Not IaC.** Netmaker runs on a VPS and is managed entirely through its web
dashboard, outside every Terraform tree in this repo. This file is a runbook
for the mesh + phone VPN, so the out-of-band setup is written down somewhere.

Edition: Community · Server v1.5.0.

## Topology — `public-lab` network

Mesh subnet `10.67.88.0/24`.

Public IPs are deliberately not recorded here — read them off the dashboard.

| Node | Mesh IP | Role |
|---|---|---|
| `prd-server` | 10.67.88.2 | VPS, gateway |
| `public-gateway` | 10.67.88.3 | **homelab VM**, egress gateway |

`public-gateway` is a VM on the home network, not a VPS — it's the door into
the homelab and the intended internet exit for phone full-tunnel.

### Egress routes (Egress tab)

| Name | CIDR | Peer | NAT | Purpose |
|---|---|---|---|---|
| `lab` | `10.0.0.0/24` | public-gateway | Direct | reach homelab LAN over the mesh |

Home LAN `10.0.0.0/24` is already advertised into the mesh, so any mesh client
can reach homelab boxes. There is **no** `0.0.0.0/0` egress by design — phone
full-tunnel is scoped on the phone (see below) so `prd-server` is never pulled
onto a home-exit route.

## Phone VPN (GrapheneOS)

Client: **WireGuard app** (F-Droid / GitHub build preferred — no Google deps).
Netmaker Community exports a plain WireGuard config; no Netmaker app needed.

### 1. Generate the phone config

Dashboard → Nodes → **Config files** tab → create a config for `public-lab`,
attach to gateway **public-gateway**. Netmaker returns a `.conf` + QR. The
config already includes `10.0.0.0/24` and `10.67.88.0/24` in `AllowedIPs`
(via the `lab` egress) → homelab reachable out of the box (split-tunnel).

### 2. Two tunnels = mode switch

Import the config twice, differing only in `AllowedIPs`:

- **homelab-split** — `AllowedIPs = 10.0.0.0/24, 10.67.88.0/24`
  homelab + mesh only; normal internet stays on the local link.
- **homelab-full** — `AllowedIPs = 0.0.0.0/0, ::/0`
  everything routes through home. Use on untrusted WiFi.

Tap a tunnel to switch. No dashboard change flips modes — the phone decides.

### 3. Server-side requirement for full-tunnel

`homelab-full` only reaches the internet if `public-gateway` masquerades
`0.0.0.0/0` out its WAN. The `lab` egress is `Direct` (correct for the
`/24`), but internet needs NAT. Add an egress:

Egress → Add route → CIDR `0.0.0.0/0`, peer **public-gateway**, NAT mode
**NAT**. Do *not* attach `prd-server` or any other client to it — only the
phone uses `0.0.0.0/0`, and it does so via its own `AllowedIPs`, so nothing
else needs to be on this route.

<!-- ponytail: full-tunnel scoping lives on the phone (AllowedIPs), not a
     network-wide egress — smaller blast radius, no other node affected. -->

### 4. GrapheneOS hardening

- **Settings → Network → VPN → WireGuard → "Block connections without VPN"** —
  kill-switch; no leaks if the tunnel drops. Recommended for the `homelab-full`
  use case.
- WireGuard **Excluded applications** (per tunnel) — carve specific apps out of
  the tunnel (e.g. a banking app that dislikes foreign exit IPs).

## Endpoint note (dynamic WAN)

The phone connects to `public-gateway`'s reachable endpoint. Home WAN IP is
dynamic (see `crons/public-ip-monitor/`). If the config pins a raw IP, the
tunnel breaks on IP change — prefer a DDNS hostname for the endpoint, or
re-export the config after a change.
