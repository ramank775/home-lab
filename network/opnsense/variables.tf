variable "opnsense_uri" {
  description = "OPNsense API endpoint, e.g. https://10.0.0.1/"
  type        = string
}

variable "opnsense_api_key" {
  description = "OPNsense API key (System → Access → Users → API keys)."
  type        = string
  sensitive   = true
}

variable "opnsense_api_secret" {
  description = "OPNsense API secret paired with the key."
  type        = string
  sensitive   = true
}

variable "opnsense_allow_insecure" {
  description = "Skip TLS verification (true for self-signed OPNsense certs)."
  type        = bool
  default     = true
}

variable "vlan_cisco_mgmt" {
  description = "Cisco switch management VLAN: VLAN interface only."
  type = object({
    description = string
    device      = string
    tag         = number
    parent      = string
  })
}

variable "vlan_homelab" {
  description = "Homelab services VLAN: VLAN interface + DHCP subnet + reservations."
  type = object({
    interface = object({
      description = string
      device      = string
      tag         = number
      parent      = string
    })
    dhcp_subnet = object({
      subnet      = string
      description = optional(string)
      pools       = optional(list(string), [])
      routers     = optional(list(string), [])
      dns_servers = optional(list(string), [])
      ntp_servers = optional(list(string), [])
    })
    reservations = map(object({
      hostname    = string
      ip_address  = string
      mac_address = string
      description = optional(string, "")
    }))
  })
}
