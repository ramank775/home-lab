module "home_assistance" {
  source        = "../../../tf-modules/proxmox-vm"
  name          = "home-assistance"
  node_name     = var.node_name
  vm_id         = 7000
  description   = "<div align='center'><a href='https://Helper-Scripts.com' target='_blank' rel='noopener noreferrer'><img src='https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/misc/images/logo-81x112.png'/></a>\n\n  # Home Assistant OS\n\n  <a href='https://ko-fi.com/D1D7EP4GF'><img src='https://img.shields.io/badge/&#x2615;-Buy me a coffee-blue' /></a>\n  </div>"
  on_boot       = false
  bios          = "ovmf"
  tablet_device = false
  boot_order    = ["scsi0"]
  tags          = ["community-script"]
  started       = false

  cpu    = { cores = 2 }
  memory = { dedicated = 4096 }

  disks = [{
    datastore_id = "fs-1"
    interface    = "scsi0"
    size         = 32
    cache        = "writethrough"
    discard      = "on"
    ssd          = true
  }]

  efi_disk = {
    datastore_id = "fs-1"
  }

  network_devices = [{
    bridge = "vmbr0"
  }]

  agent = {
    enabled = true
    trim    = false
  }
}
