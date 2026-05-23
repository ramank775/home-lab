locals {
  cloud_init = {
    datastore_id = "fast-storage"
    interface    = "ide2"
    upgrade      = true
    ipv4         = { address = "dhcp" }
    user_account = {
      username = "debian"
      keys     = []
    }
  }
}

module "k3s_1" {
  source    = "../_base/proxmox-vm"
  name      = "k3s-1"
  node_name = var.node_name
  vm_id     = 4000
  on_boot   = true

  cpu    = { cores = 4, hotplugged = 4 }
  memory = { dedicated = 8192, floating = 4096 }

  disks = [{
    datastore_id = "fast-storage"
    interface    = "scsi0"
    size         = 50
  }]

  network_devices = [{
    bridge = "vmbr0"
  }]

  agent      = { enabled = true }
  cloud_init = local.cloud_init
}

module "k3s_node_1" {
  source    = "../_base/proxmox-vm"
  name      = "k3s-node-1"
  node_name = var.node_name
  vm_id     = 4001
  on_boot   = true

  cpu    = { cores = 4, hotplugged = 4 }
  memory = { dedicated = 8192 }

  disks = [{
    datastore_id = "fast-storage"
    interface    = "scsi0"
    size         = 50
  }]

  network_devices = [{
    bridge = "vmbr0"
  }]

  agent      = { enabled = true }
  cloud_init = local.cloud_init
}
