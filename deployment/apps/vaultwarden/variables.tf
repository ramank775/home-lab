
variable "namespace" {
  type        = string
  description = "kubernetes namepsace for visitor apps client"
  default     = "homelab_apps"
}

variable "domain" {
  type        = string
  description = "Internal service domain for vaultwarden endpoint"
}

variable "public_domain" {
  type        = string
  description = "Public domain for vaultwarden"
}

variable "smtp_options" {
  type        = map(string)
  description = "SMTP options"
  default = {
    "host"     = "homelab.arpa"
    "port"     = 25
    "security" = "off"
  }
}

variable "sender_mail" {
  type        = string
  description = "Sender mail for vaultwarden"
  default     = "vaultwarden@homelab.arpa"
}
