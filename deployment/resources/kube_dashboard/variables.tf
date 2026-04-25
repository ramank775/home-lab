variable "domain" {
  type        = string
  description = "Default Domain name cluster endpoint"
}

variable "chart_version" {
  type        = string
  description = "Helm chart version for kubernetes-dashboard"
}
