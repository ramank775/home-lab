// Cisco switch management VLAN. Currently just the VLAN interface — no DHCP,
// no reservations, no firewall rules under Terraform management yet.

resource "opnsense_interfaces_vlan" "this" {
  description = var.vlan.description
  device      = var.vlan.device
  tag         = var.vlan.tag
  parent      = var.vlan.parent
}
