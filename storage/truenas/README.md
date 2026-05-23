# storage/truenas

Terraform-managed TrueNAS SCALE: datasets, NFS/SMB shares, snapshot tasks,
and users.

Mirrors the layout of `network/opnsense/` and `hypervisor/proxmox/`:
top-level dir = domain (`storage/`), inner dir = system (`truenas/`),
inside groups by *workload purpose* (media, backups, vm_storage, etc.).

```
storage/truenas/
├── provider.tf, versions.tf, variables.tf, main.tf, imports.tf
└── <group>/        # one subdir per workload purpose (added during discovery)
```

Per-system secrets/config: `.lab/storage/truenas/values.tfvars` (gitignored).
State: `.lab/storage/truenas/terraform.tfstate` via a relative-path local
backend.

## Prereqs (one-time, in TrueNAS UI)

1. Open `https://10.0.0.30/`, log in.
2. User icon (top-right) → **API Keys** → **Add**.
3. Name it `terraform`, pick an expiration (1 year recommended).
4. Save. Copy the displayed key — it's shown only once.
5. Fill in `.lab/storage/truenas/values.tfvars` with `truenas_api_key`.

## Initial import

```sh
cd storage/truenas
terraform init
# (discovery script will be added here after probing the API)
terraform plan -var-file=../../.lab/storage/truenas/values.tfvars
terraform apply
```

## Provider note

Uses `dariusbakunas/truenas`. Coverage is good for datasets, NFS/SMB shares,
users, snapshot tasks, cron. Does NOT manage: TrueNAS apps/charts (use the
UI for those), pools (managed via UI, then datasets-on-top are TF-able),
network/interface config.
