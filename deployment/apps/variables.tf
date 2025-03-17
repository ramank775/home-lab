variable "namespace" {
  type        = string
  description = "Kubernetes namespace for apps"
  default     = "homelab-apps"
}

variable "domain" {
  type        = string
  description = "Default Domain name cluster endpoint"
}

variable "replicas" {
  type        = map(number)
  description = "Replica count for resources"
  default = {
    nats_streaming_http_producer = 1
    slack_notifier               = 1
    tunnel_client                = 1
    visitor_badge                = 1
  }
}

variable "node_selector" {
  type        = map(string)
  description = "Node selector for homelab apps "
  default     = {}
}

# variable "nats_url" {
#   type        = string
#   description = "Nats cluster url"
# }

# variable "nats_cluster_id" {
#   type        = string
#   description = "Nats cluster id"
#   default     = "home-lab"
# }

# variable "slack_endpoint" {
#   type        = string
#   description = "Slack webhook endpoint"
# }

# variable "tunnel_ssh_user" {
#   type        = string
#   description = "Remote proxy server ssh user"
#   default     = "dev"
# }

# variable "tunnel_ssh_port" {
#   type        = number
#   description = "Remote proxy server ssh port"
#   default     = 22
# }

# variable "tunnel_proxy_host" {
#   type        = string
#   description = "Remote proxy server hostname"
# }

# variable "tunnel_remote_port" {
#   type        = number
#   description = "Remote proxy server port to forward"
#   default     = 8080
# }

# variable "tunnel_ssh_key" {
#   type        = string
#   description = "SSH private key for proxy server"
# }

variable "static_site_user" {
  type        = string
  description = "Static site ssh username"
}

variable "static_site_pass" {
  type        = string
  description = "static site ssh password"
  sensitive   = true
}

# variable "dovecot_config_dir" {
#   type        = string
#   description = "Local dovecot configuration directory"
# }

# variable "spampd_config_dir" {
#   type        = string
#   description = "Spampd configuration directory"
# }

# variable "mail_db_type" {
#   type        = string
#   description = "Database type"
#   default     = "mysqli"
# }

# variable "mail_db_host" {
#   type        = string
#   description = "Database host"
# }

# variable "mail_db_port" {
#   type        = string
#   description = "Database port"
#   default     = "3306"
# }

# variable "mail_db_name" {
#   type        = string
#   description = "Database name"
#   default     = "mail"
# }

# variable "mail_db_user" {
#   type        = string
#   description = "Database name"
#   default     = "mailer"
# }

# variable "mail_db_pass" {
#   type        = string
#   description = "Database password"
#   sensitive   = true
# }

# variable "mail_dns_server" {
#   type        = string
#   description = "DNS server IP for mail server"
# }

# variable "postfix_admin_setup_password" {
#   type        = string
#   description = "Postfix admin setup password"
#   sensitive   = true
# }

# variable "postfix_admin_encrypt" {
#   type        = string
#   description = "Encrypt algo for postfix admin"
#   default     = "md5crypt"
# }

variable "smtp_options" {
  type        = map(string)
  description = "smtp settings"
  default = {
    "host"     = "mail.homelab.arpa"
    "port"     = 25
    "security" = "off"
  }
}

variable "vaultwarden_options" {
  type        = map(string)
  description = "Vaultwarden options"
  default = {
  }
}

variable "blog_domain" {
  type        = string
  description = "domain for blog"
}

variable "github_config" {
  type        = map(string)
  description = "github configuration details"
}

variable "nats_streaming_http_producer_url" {
  type        = string
  description = "nats streaming http producer url"
}