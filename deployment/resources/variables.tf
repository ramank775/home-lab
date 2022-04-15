variable "cluster_domain" {
  type        = string
  description = "K8s cluster domain name"
  default     = "cluster.local"
}

variable "namespace" {
  type        = string
  description = "kubernetes namespace for resources"
  default     = "homelab-resources"
}

variable "node_selector" {
  type        = map(string)
  description = "Node selector for homelab Resources "
  default     = {}
}

variable "cloudflared_cred_file" {
  type        = string
  description = "cloudflared tunnel cred file path"
}

variable "cloudflared_config_file" {
  type        = string
  description = "cloudflared config file"
}

variable "cloudflared_cert_file" {
  type        = string
  description = "Cloudflared tunnel cert file"
}
