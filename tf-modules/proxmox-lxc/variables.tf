variable "name" {
  description = "LXC hostname (also used as the Proxmox name)."
  type        = string
}

variable "node_name" {
  description = "Proxmox node to place the container on."
  type        = string
}

variable "vm_id" {
  description = "Proxmox VM/CT ID. Required for imported containers."
  type        = number
  default     = null
}

variable "description" {
  description = "Free-text container description."
  type        = string
  default     = null
}

variable "tags" {
  description = "Proxmox tags."
  type        = list(string)
  default     = []
}

variable "started" {
  description = "Whether the container should be running."
  type        = bool
  default     = true
}

variable "start_on_boot" {
  description = "Auto-start at PVE boot."
  type        = bool
  default     = true
}

variable "unprivileged" {
  description = "Run as unprivileged container."
  type        = bool
  default     = true
}

variable "cpu" {
  description = "CPU settings."
  type = object({
    cores        = number
    architecture = optional(string, "amd64")
  })
}

variable "memory" {
  description = "Memory settings (MiB)."
  type = object({
    dedicated = number
    swap      = optional(number, 512)
  })
}

variable "disk" {
  description = "Root disk."
  type = object({
    datastore_id = string
    size         = number # GiB
  })
}

variable "features" {
  description = "LXC features (keyctl needed for nginx proxy manager / docker-in-LXC)."
  type = object({
    nesting = optional(bool, true)
    keyctl  = optional(bool, false)
    fuse    = optional(bool, false)
    mknod   = optional(bool, false)
  })
  default = {}
}

variable "initialization" {
  description = "Container initialization (hostname + IP). Required."
  type = object({
    hostname = string
    ipv4 = object({
      address = string # e.g. "10.0.0.42/24" or "dhcp"
      gateway = optional(string)
    })
  })
}

variable "network" {
  description = "Primary network interface."
  type = object({
    bridge      = optional(string, "vmbr0")
    name        = optional(string, "eth0")
    mac_address = optional(string) # set for imported containers
    firewall    = optional(bool, false)
    vlan_id     = optional(number)
  })
  default = {}
}

variable "operating_system" {
  description = "Container OS type."
  type = object({
    type             = optional(string, "debian")
    template_file_id = optional(string)
  })
  default = {}
}

variable "mount_points" {
  description = "Additional mount points (data volumes, bind mounts)."
  type = list(object({
    path      = string
    volume    = string           # storage:vmid-disk-N or host path
    size      = optional(string) # e.g. "50G" (only for storage-backed volumes)
    backup    = optional(bool, true)
    replicate = optional(bool, true)
    read_only = optional(bool, false)
    shared    = optional(bool, false)
  }))
  default = []
}

variable "startup" {
  description = "Boot ordering (only set if you need specific order)."
  type = object({
    order      = number
    up_delay   = optional(number, -1)
    down_delay = optional(number, -1)
  })
  default = null
}

variable "console" {
  description = "Console settings."
  type = object({
    enabled   = optional(bool, true)
    tty_count = optional(number, 2)
    type      = optional(string, "tty")
  })
  default = {}
}
