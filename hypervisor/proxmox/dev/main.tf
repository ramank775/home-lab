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

module "talocity" {
  source    = "../_base/proxmox-vm"
  name      = "talocity"
  node_name = var.node_name
  vm_id     = 10007
  started   = false

  cpu    = { cores = 4, hotplugged = 4 }
  memory = { dedicated = 10240 }

  disks = [{
    datastore_id = "fast-storage"
    interface    = "scsi0"
    size         = 50
    backup       = false
  }]

  network_devices = [{
    bridge   = "vmbr0"
    firewall = true
  }]

  agent      = { enabled = true }
  cloud_init = local.cloud_init
}

module "ai_dev" {
  source    = "../_base/proxmox-vm"
  name      = "ai-dev"
  node_name = var.node_name
  vm_id     = 10008
  started   = false

  cpu    = { cores = 4, hotplugged = 4 }
  memory = { dedicated = 8192 }

  disks = [{
    datastore_id = "fast-storage"
    interface    = "scsi0"
    size         = 30
  }]

  network_devices = [{
    bridge   = "vmbr0"
    firewall = true
  }]

  agent      = { enabled = true }
  cloud_init = local.cloud_init
}

module "spampd_dev" {
  source    = "../_base/proxmox-vm"
  name      = "spampd-dev"
  node_name = var.node_name
  vm_id     = 10006
  started   = false

  cpu    = { cores = 4, hotplugged = 4 }
  memory = { dedicated = 8192 }

  disks = [{
    datastore_id = "fast-storage"
    interface    = "scsi0"
    size         = 10
  }]

  network_devices = [{
    bridge   = "vmbr0"
    firewall = true
  }]

  agent      = { enabled = true }
  cloud_init = local.cloud_init
}
