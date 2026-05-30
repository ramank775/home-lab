output "id" {
  description = "Proxmox VM ID assigned by the cluster."
  value       = proxmox_virtual_environment_vm.this.vm_id
}

output "name" {
  description = "VM name."
  value       = proxmox_virtual_environment_vm.this.name
}

output "ipv4_addresses" {
  description = "IPv4 addresses reported by the guest agent (empty if agent not running)."
  value       = proxmox_virtual_environment_vm.this.ipv4_addresses
}
