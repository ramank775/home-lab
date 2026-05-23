output "id" {
  description = "Proxmox VM/CT ID."
  value       = proxmox_virtual_environment_container.this.vm_id
}

output "name" {
  description = "Container hostname."
  value       = proxmox_virtual_environment_container.this.initialization[0].hostname
}
