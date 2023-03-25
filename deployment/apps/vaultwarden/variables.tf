
variable "namespace" {
  type        = string
  description = "kubernetes namepsace for visitor apps client"
  default     = "homelab_apps"
}

variable "domain" {
  type        = string
  description = "Internal service domain for vaultwarden endpoint"
}
