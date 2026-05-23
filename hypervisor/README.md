# hypervisor

Terraform-managed Proxmox hosts. Each host lives in its own root module
(`proxmox/`, `<host2>/`, ...) with independent state, so issues on one host
don't block plans on another.

## Layout

```
hypervisor/
├── modules/
│   └── proxmox-vm/      # shared VM module used by every host
└── proxmox/                # one root module per Proxmox host
    ├── provider.tf
    ├── versions.tf
    ├── variables.tf
    ├── main.tf
    ├── imports.tf       # `import` blocks for existing VMs (generated)
    └── scripts/
        └── generate-imports.sh
```

Non-secret + secret config lives at `.lab/hypervisor/<host>/values.tfvars`
(`.lab/` is gitignored — matches the existing `deployment/` convention).

## Initial setup for a host

1. On the Proxmox host, create a dedicated API user and token:

   ```sh
   pveum user add terraform@pve
   pveum aclmod / -user terraform@pve -role PVEAdmin   # tighten later
   pveum user token add terraform@pve provisioner --privsep=0
   ```

   Copy the token value — it's shown only once.

2. Fill in `.lab/hypervisor/<host>/values.tfvars` (see the template in
   `proxmox/` and copy its shape).

3. Initialize and import existing VMs:

   ```sh
   cd hypervisor/<host>
   terraform init
   ./scripts/generate-imports.sh    # writes imports.tf
   terraform plan \
     -var-file=/home/raman/git/home-lab/.lab/hypervisor/<host>/values.tfvars \
     -generate-config-out=generated.tf
   ```

   Review `generated.tf`, then `terraform apply` to bring the imports into
   state. After the first successful apply, refactor `generated.tf` resources
   to call `../modules/proxmox-vm` at your own pace.

## Adding a new Proxmox host

```sh
cp -r hypervisor/proxmox hypervisor/pveN
cp -r .lab/hypervisor/proxmox .lab/hypervisor/pveN
# edit hypervisor/pveN/provider.tf  → endpoint
# edit .lab/hypervisor/pveN/values.tfvars  → endpoint, token, node name
cd hypervisor/pveN && terraform init
```

Then follow the initial-setup import flow above.

## Why per-host root modules

A single root module with provider aliases would mean one broken host blocks
all plans. Per-host root modules give each host independent state and blast
radius. The shared `modules/proxmox-vm/` keeps VM semantics consistent.
