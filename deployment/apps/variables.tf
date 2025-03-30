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

variable "shared_db" {
  type = object({
    host = string
    port = number
  })
}

variable "minio" {
  description = "values for minio"
  type = object({
    server = string
  })
}

variable "n8n_license_key" {
  description = "The n8n license key"
  type        = string
  sensitive   = true
}
