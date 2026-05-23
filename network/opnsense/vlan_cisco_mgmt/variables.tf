variable "vlan" {
  description = "VLAN interface definition."
  type = object({
    description = string
    device      = string
    tag         = number
    parent      = string
  })
}
