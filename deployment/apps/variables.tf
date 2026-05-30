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

variable "node_name" {
  type        = string
  description = "Proxmox node to place Proxmox-backed apps on."
}

variable "ips" {
  description = "Static IP assignments for LXCs (passed through to apps that need them)."
  type = map(object({
    address = string
    gateway = string
  }))
  default = {}
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

variable "postiz" {
  type = object({
    domain                  = string
    social_credentials_file = string
    email = object({
      user    = string
      pass    = string
      address = string
    })
  })
}

variable "joplin" {
  description = "Joplin server configuration"
  type = object({
    email = object({
      from_name    = string
      from_address = string
      reply_to     = optional(string)
    })
  })
  default = {
    email = {
      from_name    = "Joplin"
      from_address = "joplin@homelab.arpa"
    }
  }
}

variable "visitor_badge" {
  description = "Visitor badge configuration"
  type = object({
    md5_key       = string
    admin_api_key = string
  })
  sensitive = true
}

variable "crawl4ai" {
  description = "Crawl4AI configuration"
  type = object({
    llm_credential_file = string
  })
}

variable "plausible" {
  description = "Plausible configuration"
  type = object({
    url = string
    clickhouse = object({
      url = string
    })
    mailer = object({
      name  = string
      email = string
    })
    google_oauth_credentials_file_path = string
  })
  default = {
    url = "https://plausible.example.com"
    clickhouse = {
      url = "http://clickhouse.example.com:8123"
    }
    mailer = {
      name  = "Plausible Analytics"
      email = "plausible@example.com"
    }
    google_oauth_credentials_file_path = "/path/to/google_oauth_credentials.json"
  }
}

variable "searxng_chart_version" {
  type        = string
  description = "Helm chart version for searxng"
}

variable "n8n_chart_version" {
  type        = string
  description = "Helm chart version for n8n"
}

variable "n8n_image_tag" {
  type        = string
  description = "n8n container image tag"
}

variable "postiz_image_tag" {
  type        = string
  description = "postiz container image tag"
}

variable "plausible_version" {
  type        = string
  description = "Plausible container image tag"
}

variable "joplin_image_tag" {
  type        = string
  description = "joplin/server container image tag"
}

variable "visitor_badge_image_tag" {
  type        = string
  description = "visitor-badge container image tag"
}

variable "visitor_badge_backup_image_tag" {
  type        = string
  description = "visitor-badge backup sidecar image tag"
}

variable "crawl4ai_image_tag" {
  type        = string
  description = "crawl4ai container image tag"
}

variable "blog_feature_post_image_tag" {
  type        = string
  description = "Image tag for blog feature post cron"
}

variable "blog_oauth_provider_image_tag" {
  type        = string
  description = "Image tag for netlify-cms OAuth provider"
}

variable "vaultwarden_image_tag" {
  type        = string
  description = "vaultwarden/server container image tag"
}

variable "vaultwarden_nginx_image_tag" {
  type        = string
  description = "Image tag for vaultwarden's nginx sidecar"
}

variable "redis_image_tag" {
  type        = string
  description = "Shared image tag for the redis sidecar used in postiz/visitor-badge/mail"
}

variable "busybox_image_tag" {
  type        = string
  description = "Image tag for busybox init containers"
}