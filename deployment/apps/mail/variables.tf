variable "namespace" {
  type        = string
  description = "kubernetes namepsace to host nats streaming http producer"
  default     = "homelab_apps"
}

variable "tag" {
  description = "dovecot image tag"
  default     = "2.3.20"
  sensitive   = false
  type        = string
}

variable "tunnel_client_tag" {
  description = "tunnel client image tag"
  default     = "v0.0.6"
  sensitive   = false
  type        = string
}

variable "spampd_tag" {
  description = "spampd image tag"
  default     = "v2.61"
  sensitive   = false
  type        = string
}

variable "dovecot_config_dir" {
  type        = string
  description = "Local dovecot configuration directory"
}

variable "spampd_config_dir" {
  type        = string
  description = "Spampd configuration directory"
}

variable "tunnel_ssh_user" {
  type        = string
  description = "Remote proxy server ssh user"
  default     = "dev"
}

variable "tunnel_ssh_port" {
  type        = number
  description = "Remote proxy server ssh port"
  default     = 22
}

variable "tunnel_proxy_host" {
  type        = string
  description = "Remote proxy server hostname"
}

variable "tunnel_ssh_key" {
  type        = string
  description = "SSH private key of proxy server"
}
