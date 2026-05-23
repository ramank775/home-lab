module "vlan_cisco_mgmt" {
  source = "./vlan_cisco_mgmt"
  vlan   = var.vlan_cisco_mgmt
}

module "vlan_homelab" {
  source       = "./vlan_homelab"
  vlan         = var.vlan_homelab.interface
  dhcp_subnet  = var.vlan_homelab.dhcp_subnet
  reservations = var.vlan_homelab.reservations
}
