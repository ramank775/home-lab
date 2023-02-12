variable "kube_config" {
  type = string
}

variable "kube_host" {
  type = string
}

variable "kube_insecure" {
  type    = bool
  default = false
}

variable "namespace" {
  type        = string
  description = "Namespace for resources"
  default     = "homelab-resources"
}

variable "domain" {
  type        = string
  description = "Domain name to access resource"
}

variable "node_selector" {
  type        = map(string)
  description = "Node selector for homelab Resources "
  default     = {}
}

variable "lb_iprange" {
  type        = string
  description = "Load Balancer IP range"
}

variable "versions" {
  type        = map(string)
  description = "Resources Version"
}

variable "pihole_config_dir" {
  type        = string
  description = "Pihole config director contains adlists and local dns"
}

variable "truenas" {
  type = map(string)
  default = {
    "host"   = "10.0.0.30"
    "port"   = 80
    "pool"   = "pool-1"
    "apikey" = ""
  }
}

variable "cloudflared" {
  type = map(string)
  default = {
    "cred_file"   = ""
    "config_file" = ""
    "cert_file"   = ""
  }
  description = "cloudflared tunnel options"
}
