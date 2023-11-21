variable "domain" {
  type        = string
  description = "Default Domain name cluster endpoint"
}

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

variable "replicas" {
  type        = map(number)
  description = "Replica count for resources"
  default = {
    nats = 0
    smtp_relay = 1
  }
}

variable "pihole_config_dir" {
  type        = string
  description = "Pihole config director contains adlists and local dns"
}

variable "cloudflared" {
  type = map(string)
  description = "cloudflared tunnel options"
}


variable "smtp_relay_host" {
  description = "SMTP Relay server"
  type = string
}

variable "smtp_relay_user" {
  description = "SMTP Relay server username"
  type = string
}

variable "smtp_relay_pass" {
  description = "SMTP Relay sever password"
  type = string
  sensitive = true
}