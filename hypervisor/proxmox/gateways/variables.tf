variable "node_name" {
  description = "Proxmox node to place guests on."
  type        = string
}

variable "ips" {
  description = "Static IP assignments map (from root)."
  type = map(object({
    address = string
    gateway = string
  }))
  default = {}
}
