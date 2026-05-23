variable "vlan" {
  description = "VLAN interface definition."
  type = object({
    description = string
    device      = string
    tag         = number
    parent      = string
  })
}

variable "dhcp_subnet" {
  description = "DHCPv4 subnet served on this VLAN."
  type = object({
    subnet      = string
    description = optional(string)
    pools       = optional(list(string), [])
    routers     = optional(list(string), [])
    dns_servers = optional(list(string), [])
    ntp_servers = optional(list(string), [])
  })
}

variable "reservations" {
  description = "Static DHCP reservations on this VLAN."
  type = map(object({
    hostname    = string
    ip_address  = string
    mac_address = string
    description = optional(string, "")
  }))
  default = {}
}
