variable "namespace" {
  type        = string
  description = "kubernetes namepsace to host nats streaming http producer"
  default     = "mail"
}

variable "dovecot-tag" {
  description = "dovecot image tag"
  default     = "2.3.21"
  sensitive   = false
  type        = string
}

variable "dovecot_config_dir" {
  type        = string
  description = "Local dovecot configuration directory"
}

variable "spampd_tag" {
  description = "spampd image tag"
  default     = "v2.70.0-rc.1"
  sensitive   = false
  type        = string
}

variable "spampd_config_dir" {
  type        = string
  description = "Spampd configuration directory"
}

variable "spamassassin_tag" {
  description = "spampd image tag"
  default     = "latest"
  sensitive   = false
  type        = string
  
}

variable "mail_dns_server" {
  type = string
  description = "Load balancer IP for mail dns server"
}