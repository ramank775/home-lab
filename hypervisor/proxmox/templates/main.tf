module "debian_cloud" {
  source    = "../_base/proxmox-vm"
  name      = "debian-cloud"
  node_name = var.node_name
  vm_id     = 90000
  template  = true

  cpu    = { cores = 1, hotplugged = 1 }
  memory = { dedicated = 4096 }

  disks = [{
    datastore_id = "fast-storage"
    interface    = "scsi0"
    size         = 10
  }]

  network_devices = [{
    bridge   = "vmbr0"
    firewall = true
  }]

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
