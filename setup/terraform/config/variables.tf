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

variable "lb_iprange" {
  type        = string
  description = "Load Balancer IP range"
}

variable "pihole_config_dir" {
  type        = string
  description = "Pihole config director contains adlists and local dns"
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

variable "namespace" {
  type        = string
  description = "Namespace for resources"
  default     = "homelab-resources"
}
