variable "cluster_domain" {
  type        = string
  description = "K8s cluster domain name"
  default     = "cluster.local"
}

variable "namespace" {
  type        = string
  description = "kubernetes namepsace to host nats streaming http producer"
  default     = "mail"
}

variable "dovecot-tag" {
  description = "dovecot image tag"
  sensitive   = false
  type        = string
}

variable "dovecot_config_dir" {
  type        = string
  description = "Local dovecot configuration directory"
}

variable "spampd_tag" {
  description = "spampd image tag"
  sensitive   = false
  type        = string
}

variable "domain" {
  type        = string
  description = "Mail domain"
  default     = "mail.homelab.arpa"
}

variable "spampd_config_dir" {
  type        = string
  description = "Spampd configuration directory"
}

variable "spamassassin_tag" {
  description = "spampd image tag"
  sensitive   = false
  type        = string
}

variable "dns_server" {
  type        = string
  description = "Load balancer IP for mail dns server"
}

variable "db_config" {
  type = object({
    type = string
    host = string
    port = number
    name = string
    user = string
    pass = string
  })
  description = "Mail database connection"
  sensitive   = true
}

variable "smtp_options" {
  type        = map(string)
  description = "smtp settings"
  default = {
    "host" = "mail.homelab.arpa"
    "port" = 25
  }
}

variable "postfix_admin_config" {
  type = object({
    encrypt  = optional(string, "md5crypt")
    password = string
  })
  description = "Postfix admin setup password"
  sensitive   = true
}

variable "postfixadmin_image_tag" {
  type        = string
  description = "Image tag for postfixadmin"
}

variable "redis_image_tag" {
  type        = string
  description = "Image tag for the redis sidecar"
}

