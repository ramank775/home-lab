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
    nats       = 0
    smtp_relay = 1
  }
}

variable "dns_server_ip" {
  type        = string
  description = "External IP for DNS server"
}

variable "pihole_config_dir" {
  type        = string
  description = "Pihole config director contains adlists and local dns"
}

variable "cloudflared" {
  type        = map(string)
  description = "cloudflared tunnel options"
}


variable "smtp_relay_host" {
  description = "SMTP Relay server"
  type        = string
}

variable "smtp_relay_user" {
  description = "SMTP Relay server username"
  type        = string
}

variable "smtp_relay_pass" {
  description = "SMTP Relay sever password"
  type        = string
  sensitive   = true
}

variable "headlamp_chart_version" {
  type        = string
  description = "Helm chart version for headlamp"
}

variable "bind9_image_tag" {
  type        = string
  description = "Container image tag for bind9"
}

variable "cloudflared_image_tag" {
  type        = string
  description = "Container image tag for cloudflared tunnel client"
}

variable "smtp_relay_image_tag" {
  type        = string
  description = "Container image tag for smtp-relay"
}

variable "pihole_image_tag" {
  type        = string
  description = "Container image tag for pihole"
}

variable "shared_db" {
  description = "Shared LXC Postgres connection. Used by Temporal for persistence/visibility DBs."
  type = object({
    host = string
    port = number
  })
}

variable "temporal_server_image_tag" {
  type        = string
  description = "Container image tag for temporalio/auto-setup"
}

variable "temporal_ui_image_tag" {
  type        = string
  description = "Container image tag for temporalio/ui"
}

variable "elasticsearch_image_tag" {
  type        = string
  description = "Container image tag for Temporal's Elasticsearch (v7 line)"
}