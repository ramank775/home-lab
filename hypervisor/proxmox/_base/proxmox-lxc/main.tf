terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">= 0.66.0"
    }
  }
}

resource "proxmox_virtual_environment_container" "this" {
  node_name     = var.node_name
  vm_id         = var.vm_id
  description   = var.description
  tags          = var.tags
  started       = var.started
  start_on_boot = var.start_on_boot
  unprivileged  = var.unprivileged

  console {
    enabled   = var.console.enabled
    tty_count = var.console.tty_count
    type      = var.console.type
  }

  cpu {
    cores        = var.cpu.cores
    architecture = var.cpu.architecture
  }

  memory {
    dedicated = var.memory.dedicated
    swap      = var.memory.swap
  }

  disk {
    datastore_id = var.disk.datastore_id
    size         = var.disk.size
  }

  features {
    nesting = var.features.nesting
    keyctl  = var.features.keyctl
    fuse    = var.features.fuse
    mknod   = var.features.mknod
  }

  initialization {
    hostname = var.initialization.hostname

    ip_config {
      ipv4 {
        address = var.initialization.ipv4.address
        gateway = var.initialization.ipv4.gateway
      }
    }
  }

  network_interface {
    bridge      = var.network.bridge
    name        = var.network.name
    mac_address = var.network.mac_address
    firewall    = var.network.firewall
    vlan_id     = var.network.vlan_id
  }

  operating_system {
    type             = var.operating_system.type
    template_file_id = var.operating_system.template_file_id == null ? "" : var.operating_system.template_file_id
  }

  dynamic "mount_point" {
    for_each = var.mount_points
    content {
      path      = mount_point.value.path
      volume    = mount_point.value.volume
      size      = mount_point.value.size
      backup    = mount_point.value.backup
      replicate = mount_point.value.replicate
      read_only = mount_point.value.read_only
      shared    = mount_point.value.shared
    }
  }

  dynamic "startup" {
    for_each = var.startup == null ? [] : [var.startup]
    content {
      order      = startup.value.order
      up_delay   = startup.value.up_delay
      down_delay = startup.value.down_delay
    }
  }

  lifecycle {
    prevent_destroy = true
  }
}
