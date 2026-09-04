module "pg_1" {
  source    = "../../tf-modules/proxmox-lxc"
  name      = "pg-1"
  node_name = var.node_name
  vm_id     = 202
  tags      = ["db"]

  cpu    = { cores = 2 }
  memory = { dedicated = 4096, swap = 512 }
  disk   = { datastore_id = "fast-storage", size = 8 }

  initialization = {
    hostname = "pg-1"
    ipv4     = var.ips["pg_1"]
  }

  mount_points = [{
    path   = "/mnt/data"
    volume = "fast-storage:vm-202-disk-1"
    size   = "50G"
  }]

  startup = { order = 2 }
}

module "pg_2" {
  source    = "../../tf-modules/proxmox-lxc"
  name      = "pg-2"
  node_name = var.node_name
  vm_id     = 203
  tags      = ["db"]

  cpu    = { cores = 2 }
  memory = { dedicated = 4096, swap = 512 }
  disk   = { datastore_id = "fs-1", size = 8 }

  initialization = {
    hostname = "pg-2"
    ipv4     = var.ips["pg_2"]
  }

  mount_points = [{
    path   = "/mnt/data"
    volume = "fs-1:vm-203-disk-1"
    size   = "50G"
    backup = false
  }]

  startup = { order = 2 }
}

module "etcd_1" {
  source    = "../../tf-modules/proxmox-lxc"
  name      = "etcd-1"
  node_name = var.node_name
  vm_id     = 200
  tags      = ["db"]

  cpu    = { cores = 2 }
  memory = { dedicated = 1024, swap = 512 }
  disk   = { datastore_id = "fast-storage", size = 8 }

  initialization = {
    hostname = "etcd-1"
    ipv4     = var.ips["etcd_1"]
  }

  mount_points = [{
    path   = "/mnt/data"
    volume = "fast-storage:vm-200-disk-3"
    size   = "10G"
  }]

  startup = { order = 1 }
}

module "clickhouse_1" {
  source    = "../../tf-modules/proxmox-lxc"
  name      = "clickhouse-1"
  node_name = var.node_name
  vm_id     = 204
  tags      = ["clickhouse", "db"]

  cpu    = { cores = 2 }
  memory = { dedicated = 8192, swap = 8192 }
  disk   = { datastore_id = "fast-storage", size = 8 }

  initialization = {
    hostname = "clickhouse-1"
    ipv4     = var.ips["clickhouse_1"]
  }

  mount_points = [{
    path   = "/mnt/data"
    volume = "fs-1:vm-204-disk-0"
    size   = "20G"
  }]
}
