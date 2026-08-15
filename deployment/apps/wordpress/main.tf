module "wp_serverless" {
  source        = "../../../tf-modules/proxmox-vm"
  name          = "wp-serverless"
  node_name     = var.node_name
  vm_id         = 5000
  on_boot       = false
  started       = false
  scsi_hardware = "virtio-scsi-single"
  boot_order    = ["scsi0", "ide2", "net0"]
  tags          = ["production"]

  cpu    = { cores = 4, hotplugged = 4 }
  memory = { dedicated = 16384 }

  disks = [
    {
      datastore_id = "fast-storage"
      interface    = "scsi0"
      size         = 42
      cache        = "writeback"
      discard      = "on"
      iothread     = true
      ssd          = true
    },
    {
      datastore_id = "fs-1"
      interface    = "scsi1"
      size         = 50
      cache        = "writeback"
      discard      = "on"
      iothread     = true
      ssd          = true
    }
  ]

  network_devices = [{
    bridge   = "vmbr1"
    firewall = true
  }]
}
