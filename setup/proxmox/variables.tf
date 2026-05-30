variable "pve_endpoint" {
  description = "Proxmox API endpoint, e.g. https://10.0.0.40:8006/"
  type        = string
}

variable "pve_api_token" {
  description = "Proxmox API token in the form `user@realm!tokenid=secret`."
  type        = string
  sensitive   = true
}

variable "pve_insecure" {
  description = "Skip TLS verification (true for self-signed Proxmox certs)."
  type        = bool
  default     = true
}

variable "pve_ssh_username" {
  description = "SSH username for provider operations that need shell access (e.g. cloud-init snippets)."
  type        = string
  default     = "root"
}

variable "pve_node_name" {
  description = "Name of the Proxmox node (single-node deployment)."
  type        = string
}
