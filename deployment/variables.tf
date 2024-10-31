variable "kube_config" {
  type        = string
  description = "path to kube config"
  default     = "~/.kube/kube_config"
}

variable "kube_host" {
  type = string
}

variable "kube_insecure" {
  type    = bool
  default = false
}

variable "namespaces" {
  type        = map(string)
  description = "Namespace for different resources"
  default = {
    apps       = "homelab-apps"
    crons      = "homelab-crons"
    resources  = "homelab-resources"
    media      = "media"
    monitoring = "monitoring"
  }
}

variable "domain" {
  type        = string
  description = "Default Domain name cluster endpoint"
  default     = "homelab.arpa"
}

variable "apps_node_selector" {
  type        = map(string)
  description = "Node selector for homelab apps"
  default = {

  }
}

variable "apps_replicas" {
  type        = map(number)
  description = "Replica count for resources"
  default = {
    nats_streaming_http_producer = 1
    slack_notifier               = 1
    tunnel_client                = 1
    visitor_badge                = 1
  }
}

variable "crons_node_selector" {
  type        = map(string)
  description = "Node selector for homelab crons"
  default = {

  }
}

variable "crons_replicas" {
  type        = map(number)
  description = "Replica count for crons"
  default = {
    public_ip_monitor  = 1
    blog_feature_posts = 1
  }
}

variable "resources_node_selector" {
  type        = map(string)
  description = "Node selector for homelab resources"
  default = {

  }
}

variable "resources_replicas" {
  type        = map(number)
  description = "Replica count for resources"
  default = {
    nats        = 1
    pihole      = 1
    cloudflared = 1
  }
}

variable "lb_iprange" {
  type        = string
  description = "Load Balancer IP range"
}

variable "slack_endpoint" {
  type        = string
  description = "Slack group wehbook endpoint"
  default     = ""
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

variable "tunnel_remote_port" {
  type        = number
  description = "Remote proxy server port to forward"
  default     = 8080
}

variable "tunnel_ssh_key" {
  type        = string
  description = "SSH private key for proxy server"
}

variable "pihole_config_dir" {
  type        = string
  description = "Pihole config director contains adlists and local dns"
}

variable "cloudflared" {
  type = map(string)
  default = {
    "cred_file"   = ""
    "config_file" = ""
    "cert_file"   = ""
  }
  description = "cloudflared tunnel options"
}

variable "static_site_user" {
  type        = string
  description = "Static site ssh username"
}

variable "static_site_pass" {
  type        = string
  sensitive   = true
  description = "static site ssh password"
}

variable "dovecot_config_dir" {
  type        = string
  description = "Local dovecot configuration directory"
}

variable "spampd_config_dir" {
  type        = string
  description = "Spampd configuration directory"
}

variable "mail_db_type" {
  type        = string
  description = "Database type"
  default     = "mysqli"
}

variable "mail_db_host" {
  type        = string
  description = "Database host"
}

variable "mail_db_port" {
  type        = string
  description = "Database port"
  default     = "3306"
}

variable "mail_db_name" {
  type        = string
  description = "Database name"
  default     = "mail"
}

variable "mail_db_user" {
  type        = string
  description = "Database name"
  default     = "mailer"
}

variable "mail_db_pass" {
  type        = string
  description = "Database password"
  sensitive   = true
}

variable "mail_dns_server" {
  type        = string
  description = "DNS server IP for mail server"
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

variable "remote_smtp_server" {
  type        = string
  description = "Smtp server"
}

variable "remote_smtp_port" {
  type        = string
  description = "Smtp port"
}

variable "remote_smtp_user" {
  type        = string
  description = "Smtp username"
  default     = "no-reply@homelab.arpa"
}

variable "remote_smtp_pass" {
  type        = string
  description = "Smtp password"
  default     = "SuPeRSeCrEt"
}

variable "vaultwarden_options" {
  type        = map(string)
  description = "Vaultwarden options"
  default = {
    "public_domain" : "https://vw.homelab.arpa"
    "from_mail" : "vaultwarden@homelab.arpa"
  }
}

variable "blog_domain" {
  type        = string
  description = "Domain for blog site"
}

variable "github_config" {
  type        = map(string)
  description = "Github configuration"
}

variable "media_storage" {
  type = map(string)
  default = {
    "host"     = ""
    "path"     = "/media"
    "capacity" = "1000Gi"
  }
}

variable "monitroing_external_ips" {
  type        = map(string)
  description = "External IP for observability/Monitoring Stack for ingress"
}
variable "monitoring_config_dir" {
  type        = string
  description = "Directory contains configuration files for monitoring"

}

