// Homelab services VLAN. Owns the VLAN interface, DHCP subnet, and static
// reservations for every guest on this network.

resource "opnsense_interfaces_vlan" "this" {
  description = var.vlan.description
  device      = var.vlan.device
  tag         = var.vlan.tag
  parent      = var.vlan.parent
}

resource "opnsense_kea_dhcpv4_subnet" "this" {
  subnet      = var.dhcp_subnet.subnet
  description = var.dhcp_subnet.description
  pools       = var.dhcp_subnet.pools
  routers     = var.dhcp_subnet.routers
  dns_servers = var.dhcp_subnet.dns_servers
  ntp_servers = var.dhcp_subnet.ntp_servers
}

resource "opnsense_kea_dhcpv4_reservation" "this" {
  for_each = var.reservations

  subnet_id   = opnsense_kea_dhcpv4_subnet.this.id
  hostname    = each.value.hostname
  ip_address  = each.value.ip_address
  mac_address = each.value.mac_address
  description = each.value.description
}
