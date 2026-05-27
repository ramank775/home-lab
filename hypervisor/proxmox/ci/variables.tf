variable "node_name" {
  description = "Proxmox node to place guests on."
  type        = string
}

variable "forgejo_runner_uuid" {
  description = "Forgejo runner UUID (passed from root)."
  type        = string
  sensitive   = true
}

variable "forgejo_runner_token" {
  description = "Forgejo runner per-runner token (passed from root)."
  type        = string
  sensitive   = true
}

variable "forgejo_runner_debian_password" {
  description = "Plain-text password for the `debian` user, baked into cloud-init user-data via chpasswd."
  type        = string
  sensitive   = true
}
