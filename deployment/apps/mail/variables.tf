variable "namespace" {
  type        = string
  description = "kubernetes namepsace to host nats streaming http producer"
  default     = "homelab_apps"
}

variable "domain" {
  type        = string
  description = "Internal service domain"
}


variable "tag" {
  description = "dovecot image tag"
  default     = "2.3.20"
  sensitive   = false
  type        = string
}

variable "tunnel_client_tag" {
  description = "tunnel client image tag"
  default     = "v0.0.6"
  sensitive   = false
  type        = string
}

variable "spampd_tag" {
  description = "spampd image tag"
  default     = "v2.61"
  sensitive   = false
  type        = string
}

variable "postfix_admin_tag" {
  description = "postafix admin image tag"
  default     = "3.3"
  sensitive   = false
  type        = string
}

variable "dovecot_config_dir" {
  type        = string
  description = "Local dovecot configuration directory"
}

variable "spampd_config_dir" {
  type        = string
  description = "Spampd configuration directory"
}

variable "db_type" {
  type        = string
  description = "Database type"
  default     = "mysqli"
}

variable "db_host" {
  type        = string
  description = "Database host"
}

variable "db_port" {
  type        = string
  description = "Database port"
  default     = "3306"
}

variable "db_name" {
  type        = string
  description = "Database name"
  default     = "mail"
}

variable "db_user" {
  type        = string
  description = "Database name"
  default     = "mailer"
}

variable "db_pass" {
  type        = string
  description = "Database password"
  sensitive   = true
}


variable "smtp_options" {
  type = map(string)
  description = "smtp settings"
  default = {
    "host" = "mail.homelab.arpa"
    "port" = 25
  }
}

variable "postfix_admin_setup_password" {
  type        = string
  description = "Postfix admin setup password"
  sensitive   = true
}

variable "postfix_admin_encrypt" {
  type        = string
  description = "Encrypt algo for postfix admin"
  default     = "md5crypt"
}

variable "tunnel_ssh_user" {
  type        = string
  description = "Remote proxy server ssh user"
  default     = "dev"
}

variable "tunnel_ssh_port" {
  type        = number
  description = "Remote proxy server ssh port"
  default     = 22
}

variable "tunnel_proxy_host" {
  type        = string
  description = "Remote proxy server hostname"
}

variable "tunnel_ssh_key" {
  type        = string
  description = "SSH private key of proxy server"
}
