variable "domain" {
  type        = string
  description = "Ingress hostname for headlamp"
}

variable "chart_version" {
  type        = string
  description = "Helm chart version for headlamp"
}
