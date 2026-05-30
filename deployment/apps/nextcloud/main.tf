module "nextcloud" {
  source       = "../../../tf-modules/proxmox-lxc"
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
