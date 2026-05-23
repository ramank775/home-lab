# network/opnsense

Terraform-managed OPNsense configuration: firewall rules, aliases, NAT, DHCP,
Unbound DNS overrides, and WireGuard.

Mirrors the layout used in `deployment/` and `hypervisor/proxmox/`:

```
network/opnsense/
├── provider.tf, versions.tf, variables.tf, main.tf, imports.tf
├── <group>/                # one subdir per workload group (rules, aliases, nat, ...)
└── scripts/
    └── generate-imports.sh
```

Per-host secrets/config: `.lab/network/opnsense/values.tfvars` (gitignored).
State: `.lab/network/opnsense/terraform.tfstate` via a relative-path local
backend.

## Prereqs (one-time, on OPNsense)

1. Install the **os-api** plugin:
   - UI → **System → Firmware → Plugins**
   - Search `os-api`, install, reboot if prompted

2. Create a dedicated API user + key:
   - UI → **System → Access → Users**
   - Create user `terraform` with full privileges (or a scoped role)
   - Edit that user → **API keys** → **+ Add**
   - Save the `key` and `secret` shown (secret is only shown once)

3. Fill in `.lab/network/opnsense/values.tfvars` with `opnsense_uri`,
   `opnsense_api_key`, `opnsense_api_secret`.

## Initial import

```sh
cd network/opnsense
terraform init
./scripts/generate-imports.sh        # writes imports.tf from live OPNsense state
terraform plan \
  -var-file=../../.lab/network/opnsense/values.tfvars \
  -generate-config-out=generated.tf
# Review generated.tf, refactor into group subdirs, then:
terraform plan -var-file=...          # verify zero destroys / zero replaces
terraform apply
```

## Why per-host isolation

Same reason as `hypervisor/<host>/` — independent state per network device
keeps blast radius small. If/when a second firewall or a switch is added,
that's a sibling directory (`network/<other>/`), not a provider alias.
