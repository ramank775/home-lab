module "public_gateway" {
  source      = "../../../tf-modules/proxmox-lxc"
  name        = "public-gateway"
  node_name   = var.node_name
  vm_id       = 2000
  description = "<div align='center'><a href='https://Helper-Scripts.com' target='_blank' rel='noopener noreferrer'><img src='https://raw.githubusercontent.com/tteck/Proxmox/main/misc/images/logo-81x112.png'/></a>\n\n  # Nginx Proxy Manager LXC\n\n  <a href='https://ko-fi.com/D1D7EP4GF'><img src='https://img.shields.io/badge/&#x2615;-Buy me a coffee-blue' /></a>\n  </div>\n"
  tags        = ["gateway"]

  cpu    = { cores = 1 }
  memory = { dedicated = 1024, swap = 512 }
  disk   = { datastore_id = "fast-storage", size = 10 }

  features = { keyctl = true }

  initialization = {
    hostname = "public-gateway"
    ipv4     = var.ips["public_gateway"]
  }

  startup = { order = 100 }
}

module "private_gateway" {
  source      = "../../../tf-modules/proxmox-lxc"
  name        = "private-gateway"
  node_name   = var.node_name
  vm_id       = 2001
  description = "<div align='center'><a href='https://Helper-Scripts.com' target='_blank' rel='noopener noreferrer'><img src='https://raw.githubusercontent.com/tteck/Proxmox/main/misc/images/logo-81x112.png'/></a>\n\n  # Nginx Proxy Manager LXC\n\n  <a href='https://ko-fi.com/D1D7EP4GF'><img src='https://img.shields.io/badge/&#x2615;-Buy me a coffee-blue' /></a>\n  </div>\n"
  tags        = ["gateway"]

  cpu    = { cores = 1 }
  memory = { dedicated = 1024, swap = 512 }
  disk   = { datastore_id = "fast-storage", size = 4 }

  features = { keyctl = true }

  initialization = {
    hostname = "private-gateway"
    ipv4     = var.ips["private_gateway"]
  }

  startup = { order = 100 }
}

module "haproxy_1" {
  source    = "../../../tf-modules/proxmox-lxc"
  name      = "haproxy-1"
  node_name = var.node_name
  vm_id     = 2002
  tags      = ["gateway"]

  cpu    = { cores = 1 }
  memory = { dedicated = 512, swap = 512 }
  disk   = { datastore_id = "fast-storage", size = 8 }

  initialization = {
    hostname = "haproxy-1"
    ipv4     = var.ips["haproxy_1"]
  }

  startup = { order = 100 }
}
