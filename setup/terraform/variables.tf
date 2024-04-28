variable "kube_config" {
  type    = string
  default = "~/.kube/config"
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
  default     = "10.0.0.50-10.0.0.70"
}

variable "versions" {
  type        = map(string)
  description = "Resources Version"
  default = {
    kube_dash = "2.7.0"
  }
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

