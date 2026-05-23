// Imports group by VLAN — each module owns the resources for its VLAN.

# CISCO MGMT VLAN — just the VLAN interface
import {
  to = module.vlan_cisco_mgmt.opnsense_interfaces_vlan.this
  id = "f96e46e9-846a-43a7-bfa0-bba074ef0c59"
}

# Homelab services VLAN — interface + DHCP subnet + reservations
import {
  to = module.vlan_homelab.opnsense_interfaces_vlan.this
  id = "787d89b6-5b42-4114-87db-eb14c4e624d1"
}

import {
  to = module.vlan_homelab.opnsense_kea_dhcpv4_subnet.this
  id = "4e4123a9-5777-4fab-8030-c3eccf47605b"
}

import {
  to = module.vlan_homelab.opnsense_kea_dhcpv4_reservation.this["truenas"]
  id = "8360a7d1-a9d4-40fe-9ac9-df38194e6491"
}

import {
  to = module.vlan_homelab.opnsense_kea_dhcpv4_reservation.this["k3s_master_1"]
  id = "525c5165-09ea-4d35-b5f5-7850c7c4af8f"
}

import {
  to = module.vlan_homelab.opnsense_kea_dhcpv4_reservation.this["k3s_node_1"]
  id = "42fd48e8-f71d-40da-9152-34f8df95de29"
}

import {
  to = module.vlan_homelab.opnsense_kea_dhcpv4_reservation.this["pi1"]
  id = "31af1cbd-52e6-47db-a1c8-12549e215f9b"
}

import {
  to = module.vlan_homelab.opnsense_kea_dhcpv4_reservation.this["pi2"]
  id = "beba2fb4-d6b4-490e-943d-bf28906a0503"
}

import {
  to = module.vlan_homelab.opnsense_kea_dhcpv4_reservation.this["pi3"]
  id = "330452cc-0199-4ad2-ae3a-6a7b403f0848"
}
