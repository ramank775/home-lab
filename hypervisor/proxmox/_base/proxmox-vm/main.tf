terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">= 0.66.0"
    }
  }
}

resource "proxmox_virtual_environment_vm" "this" {
  name            = var.name
  node_name       = var.node_name
  vm_id           = var.vm_id
  description     = var.description
  tags            = var.tags
  started         = var.template ? false : var.started
  on_boot         = var.on_boot
  template        = var.template
  bios            = var.bios
  scsi_hardware   = var.scsi_hardware
  keyboard_layout = var.keyboard_layout
  boot_order      = var.boot_order
  tablet_device   = var.tablet_device

  cpu {
    cores      = var.cpu.cores
    sockets    = var.cpu.sockets
    type       = var.cpu.type
    numa       = var.cpu.numa
    hotplugged = var.cpu.hotplugged
  }

  memory {
    dedicated = var.memory.dedicated
    floating  = var.memory.floating
  }

  dynamic "disk" {
    for_each = var.disks
    content {
      datastore_id = disk.value.datastore_id
      interface    = disk.value.interface
      size         = disk.value.size
      file_format  = disk.value.file_format
      iothread     = disk.value.iothread
      discard      = disk.value.discard
      ssd          = disk.value.ssd
      cache        = disk.value.cache
      aio          = disk.value.aio
      backup       = disk.value.backup
    }
  }

  dynamic "network_device" {
    for_each = var.network_devices
    content {
      bridge      = network_device.value.bridge
      model       = network_device.value.model
      vlan_id     = network_device.value.vlan_id
      firewall    = network_device.value.firewall
      mac_address = network_device.value.mac_address
    }
  }

  dynamic "agent" {
    for_each = var.agent == null ? [] : [var.agent]
    content {
      enabled = agent.value.enabled
      trim    = agent.value.trim
      timeout = agent.value.timeout
    }
  }

  dynamic "initialization" {
    for_each = var.cloud_init == null ? [] : [var.cloud_init]
    content {
      datastore_id = initialization.value.datastore_id
      interface    = initialization.value.interface
      upgrade      = initialization.value.upgrade

      ip_config {
        ipv4 {
          address = initialization.value.ipv4.address
          gateway = initialization.value.ipv4.gateway
        }
      }

      dynamic "user_account" {
        for_each = initialization.value.user_account == null ? [] : [initialization.value.user_account]
        content {
          username = user_account.value.username
          password = user_account.value.password
          keys     = user_account.value.keys
        }
      }
    }
  }

  dynamic "efi_disk" {
    for_each = var.efi_disk == null ? [] : [var.efi_disk]
    content {
      datastore_id = efi_disk.value.datastore_id
      file_format  = efi_disk.value.file_format
      type         = efi_disk.value.type
    }
  }

  operating_system {
    type = var.os_type
  }

  lifecycle {
    prevent_destroy = true

    # PVE owns the assigned MAC address. Including it in our config means
    # drift if PVE ever regenerates it. We track everything else about the
    # NIC (bridge, vlan, firewall flag) — just not the MAC.
    ignore_changes = [
      mac_addresses,
    ]
  }
}
