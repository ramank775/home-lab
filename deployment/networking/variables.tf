variable "namespaces" {
  type        = map(string)
  description = "networking namespaces"
  default = {
    "metallb" = "metallb-system"
  }
}

variable "lb_iprange" {
  type        = string
  description = "Load Balancer IP range"
}
