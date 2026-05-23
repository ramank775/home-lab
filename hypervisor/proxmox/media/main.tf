module "qbittorrent" {
  source      = "../_base/proxmox-lxc"
  name        = "qbittorrent"
  node_name   = var.node_name
  vm_id       = 1002
  description = "<div align='center'><a href='https://Helper-Scripts.com' target='_blank' rel='noopener noreferrer'><img src='https://raw.githubusercontent.com/tteck/Proxmox/main/misc/images/logo-81x112.png'/></a>\n\n  # qBittorrent LXC\n\n  <a href='https://ko-fi.com/D1D7EP4GF'><img src='https://img.shields.io/badge/&#x2615;-Buy me a coffee-blue' /></a>\n  </div>\n"
  tags        = ["media"]

  cpu    = { cores = 2 }
  memory = { dedicated = 4196, swap = 512 }
  disk   = { datastore_id = "fast-storage", size = 8 }

  features = { keyctl = true }

  initialization = {
    hostname = "qbittorrent"
    ipv4     = { address = "10.0.0.43/24", gateway = "10.0.0.1" }
  }

  network = {
    mac_address = "BC:24:11:56:03:41"
  }

  mount_points = [{
    path   = "/data/download/"
    volume = "/mnt/bigbox/media/download/"
    backup = false
  }]
}

module "jellyfin" {
  source      = "../_base/proxmox-lxc"
  name        = "jellyfin"
  node_name   = var.node_name
  vm_id       = 1001
  description = "<div align='center'><a href='https://Helper-Scripts.com' target='_blank' rel='noopener noreferrer'><img src='https://raw.githubusercontent.com/tteck/Proxmox/main/misc/images/logo-81x112.png'/></a>\n\n  # Jellyfin LXC\n\n  <a href='https://ko-fi.com/D1D7EP4GF'><img src='https://img.shields.io/badge/&#x2615;-Buy me a coffee-blue' /></a>\n  </div>\n Allow cgroup access\n Pass through device files\n"
  tags        = ["media"]

  cpu    = { cores = 8 }
  memory = { dedicated = 8192, swap = 512 }
  disk   = { datastore_id = "fast-storage", size = 8 }

  features = { keyctl = true }

  initialization = {
    hostname = "jellyfin"
    ipv4     = { address = "10.0.0.42/24", gateway = "10.0.0.1" }
  }

  network = {
    mac_address = "BC:24:11:6E:64:5E"
  }

  operating_system = { type = "ubuntu" }

  mount_points = [{
    path   = "/mnt/media/"
    volume = "/mnt/bigbox/media/"
    backup = false
  }]
}
