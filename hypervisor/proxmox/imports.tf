// Module-path imports. Each `to` address points at the .this resource inside
// the per-guest sub-module, which lives inside the workload-group module.

# k3s
import {
  to = module.k3s.module.k3s_1.proxmox_virtual_environment_vm.this
  id = "proxmox/4000"
}
import {
  to = module.k3s.module.k3s_node_1.proxmox_virtual_environment_vm.this
  id = "proxmox/4001"
}

# databases
import {
  to = module.databases.module.pg_1.proxmox_virtual_environment_container.this
  id = "proxmox/202"
}
import {
  to = module.databases.module.pg_2.proxmox_virtual_environment_container.this
  id = "proxmox/203"
}
import {
  to = module.databases.module.etcd_1.proxmox_virtual_environment_container.this
  id = "proxmox/200"
}
import {
  to = module.databases.module.clickhouse_1.proxmox_virtual_environment_container.this
  id = "proxmox/204"
}

# gateways
import {
  to = module.gateways.module.public_gateway.proxmox_virtual_environment_container.this
  id = "proxmox/2000"
}
import {
  to = module.gateways.module.private_gateway.proxmox_virtual_environment_container.this
  id = "proxmox/2001"
}
import {
  to = module.gateways.module.haproxy_1.proxmox_virtual_environment_container.this
  id = "proxmox/2002"
}

# media
import {
  to = module.media.module.qbittorrent.proxmox_virtual_environment_container.this
  id = "proxmox/1002"
}
import {
  to = module.media.module.jellyfin.proxmox_virtual_environment_container.this
  id = "proxmox/1001"
}

# dev
import {
  to = module.dev.module.talocity.proxmox_virtual_environment_vm.this
  id = "proxmox/10007"
}
import {
  to = module.dev.module.ai_dev.proxmox_virtual_environment_vm.this
  id = "proxmox/10008"
}
import {
  to = module.dev.module.spampd_dev.proxmox_virtual_environment_vm.this
  id = "proxmox/10006"
}

# templates
import {
  to = module.templates.module.debian_cloud.proxmox_virtual_environment_vm.this
  id = "proxmox/90000"
}

# one-offs
import {
  to = module.one_offs.module.nextcloud.proxmox_virtual_environment_container.this
  id = "proxmox/9000"
}
import {
  to = module.one_offs.module.home_assistance.proxmox_virtual_environment_vm.this
  id = "proxmox/7000"
}
import {
  to = module.one_offs.module.wp_serverless.proxmox_virtual_environment_vm.this
  id = "proxmox/5000"
}
