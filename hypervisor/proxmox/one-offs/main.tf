module "nextcloud" {
  source       = "../_base/proxmox-lxc"
  name         = "nextcloud"
  node_name    = var.node_name
  vm_id        = 9000
  description  = "ENDPOINT - https://drive.one9x.org\n"
  unprivileged = false

  cpu      = { cores = 4 }
  memory   = { dedicated = 4096, swap = 512 }
  disk     = { datastore_id = "fast-storage", size = 8 }
  features = { nesting = false }

  initialization = {
    hostname = "nextcloud"
    ipv4     = var.ips["nextcloud"]
  }

  network = {
    firewall = true
  }

  operating_system = { type = "ubuntu" }

  mount_points = [
    {
      path   = "/mnt/nextcloud"
      volume = "nextcloud:9000/vm-9000-disk-0.raw"
      size   = "1000G"
      backup = false
    },
    {
      path   = "/mnt/pgdata"
      volume = "fast-storage:vm-9000-disk-1"
      size   = "8G"
    }
  ]
}

module "home_assistance" {
  source        = "../_base/proxmox-vm"
  name          = "home-assistance"
  node_name     = var.node_name
  vm_id         = 7000
  description   = "<div align='center'><a href='https://Helper-Scripts.com' target='_blank' rel='noopener noreferrer'><img src='https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/misc/images/logo-81x112.png'/></a>\n\n  # Home Assistant OS\n\n  <a href='https://ko-fi.com/D1D7EP4GF'><img src='https://img.shields.io/badge/&#x2615;-Buy me a coffee-blue' /></a>\n  </div>"
  on_boot       = true
  bios          = "ovmf"
  tablet_device = false
  boot_order    = ["scsi0"]
  tags          = ["community-script"]

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

module "wp_serverless" {
  source        = "../_base/proxmox-vm"
  name          = "wp-serverless"
  node_name     = var.node_name
  vm_id         = 5000
  on_boot       = true
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
