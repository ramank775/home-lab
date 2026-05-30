
variable "domain" {
  type        = string
  description = "Default Domain name cluster endpoint"
}

variable "chart_version" {
  type        = string
  description = "Version of longhorn to install"
  default     = "1.7.2"
}
