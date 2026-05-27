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
  description = "Name of this Proxmox node (single-node deployment)."
  type        = string
}

variable "lxc_ips" {
  description = "Static IP assignments for LXCs. Map keyed by hostname; value is `<addr>/<mask>` plus gateway."
  type = map(object({
    address = string
    gateway = string
  }))
  default = {}
}

variable "forgejo_runner_uuid" {
  description = "Forgejo Actions runner UUID (from an existing runner's .runner file, server.connections.forgejo.uuid)."
  type        = string
  sensitive   = true
}

variable "forgejo_runner_token" {
  description = "Forgejo Actions runner per-runner token (from an existing runner's .runner file, server.connections.forgejo.token). NOT the one-shot registration token from the admin UI."
  type        = string
  sensitive   = true
}

variable "forgejo_runner_debian_password" {
  description = "Plain-text password for the `debian` user on the runner VM (baked into cloud-init via chpasswd)."
  type        = string
  sensitive   = true
}
