variable "cluster_domain" {
  type        = string
  description = "K8s cluster domain name"
  default     = "cluster.local"
}

variable "domain" {
  type        = string
  description = "Domain name to access resource"
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

variable "versions" {
  type        = map(string)
  description = "Resources Version"
  default = {
    democratic_csi = "0.14.7"
    metallb        = "0.14.8"
    longhorn       = "1.7.2"
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

variable "lb_iprange" {
  type        = string
  description = "Load Balancer IP range"
}