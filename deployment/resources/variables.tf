variable "cluster_domain" {
  type        = string
  description = "K8s cluster domain name"
  default     = "cluster.local"
}

variable "domain" {
  type        = string
  description = "Default Domain name cluster endpoint"
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

variable "replicas" {
  type        = map(number)
  description = "Replica count for resources"
  default = {
    nats        = 1
    pihole      = 1
    cloudflared = 1
  }
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

variable "pihole_config_dir" {
  type        = string
  description = "Pihole config director contains adlists and local dns"
}
