variable "name" {
  description = "VM name."
  type        = string
}

variable "node_name" {
  description = "Proxmox node to place the VM on."
  type        = string
}

variable "vm_id" {
  description = "Proxmox VM ID. Required for imported VMs so addresses stay stable."
  type        = number
  default     = null
}

variable "description" {
  description = "Free-text VM description."
  type        = string
  default     = null
}

variable "tags" {
  description = "Proxmox tags."
  type        = list(string)
  default     = []
}

variable "started" {
  description = "Whether the VM should be running."
  type        = bool
  default     = true
}

variable "on_boot" {
  description = "Auto-start at PVE boot."
  type        = bool
  default     = false
}

variable "template" {
  description = "Mark this VM as a template (used as a clone source). Templates are never started."
  type        = bool
  default     = false
}

variable "bios" {
  description = "BIOS implementation: \"seabios\" or \"ovmf\". OVMF requires an efi_disk block."
  type        = string
  default     = "seabios"
  validation {
    condition     = contains(["seabios", "ovmf"], var.bios)
    error_message = "bios must be \"seabios\" or \"ovmf\"."
  }
}

variable "scsi_hardware" {
  description = "SCSI controller: \"virtio-scsi-pci\" (default) or \"virtio-scsi-single\" (better for iothread)."
  type        = string
  default     = "virtio-scsi-pci"
}

variable "keyboard_layout" {
  description = "Keyboard layout for the VM."
  type        = string
  default     = "en-us"
}

variable "cpu" {
  description = "CPU settings. hotplugged should match cores for VMs imported with `vcpus` set on PVE."
  type = object({
    cores      = number
    sockets    = optional(number, 1)
    type       = optional(string, "host")
    numa       = optional(bool, false)
    hotplugged = optional(number, 0)
  })
}

variable "memory" {
  description = "Memory settings. Pass a number for dedicated-only, or an object for ballooning."
  type = object({
    dedicated = number
    floating  = optional(number, 0)
  })
}

variable "boot_order" {
  description = "Explicit boot order, e.g. [\"scsi0\", \"ide2\", \"net0\"]. Empty list = PVE default."
  type        = list(string)
  default     = []
}

variable "tablet_device" {
  description = "Enable USB tablet device (helps with mouse in console). Default true, set false for headless server VMs."
  type        = bool
  default     = true
}

variable "disks" {
  description = "List of disks. Each entry produces one disk { ... } block."
  type = list(object({
    datastore_id = string
    interface    = string # e.g. "scsi0", "virtio0"
    size         = number # GiB
    file_format  = optional(string, "raw")
    iothread     = optional(bool, false)
    discard      = optional(string, "ignore")
    ssd          = optional(bool, false)
    cache        = optional(string, "none")
    aio          = optional(string, "io_uring")
    backup       = optional(bool, true)
  }))
  default = []
}

variable "network_devices" {
  description = "List of network interfaces."
  type = list(object({
    bridge      = string
    model       = optional(string, "virtio")
    vlan_id     = optional(number)
    firewall    = optional(bool, false)
    mac_address = optional(string) # set for imported VMs so PVE state matches
  }))
  default = []
}

variable "agent" {
  description = "QEMU guest agent. Set to null to omit the block entirely."
  type = object({
    enabled = bool
    trim    = optional(bool, true)
    timeout = optional(string, "15m")
  })
  default = null
}

variable "cloud_init" {
  description = "Cloud-init initialization. Set to null to omit."
  type = object({
    datastore_id = string
    interface    = string # e.g. "ide2"
    upgrade      = optional(bool, true)
    ipv4 = object({
      address = string # "dhcp" or "10.x.x.x/24"
      gateway = optional(string)
    })
    user_account = optional(object({
      username = string
      password = optional(string)
      keys     = optional(list(string), [])
    }))
  })
  default = null
}

variable "efi_disk" {
  description = "EFI disk (required when bios = \"ovmf\")."
  type = object({
    datastore_id = string
    file_format  = optional(string, "raw")
    type         = optional(string, "4m")
  })
  default = null
  validation {
    condition     = try(var.efi_disk.datastore_id, "") != "" || var.efi_disk == null
    error_message = "efi_disk.datastore_id must be set if efi_disk is provided."
  }
}

variable "os_type" {
  description = "Proxmox OS type hint (e.g. l26 for Linux 2.6+)."
  type        = string
  default     = "l26"
}
