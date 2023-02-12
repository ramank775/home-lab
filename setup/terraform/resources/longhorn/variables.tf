
variable "domain" {
  type        = string
  description = "Default Domain name cluster endpoint"
}

variable "ver" {
  type        = string
  description = "Version of longhorn to install"
  default     = "1.3.2"
}
