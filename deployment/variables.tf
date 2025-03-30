variable "shared_db" {
  description = "Shared database configurations"
  type = object({
    type           = string
    proxy_host     = string
    host           = string
    port           = number
    user           = string
    passwd         = string
    default_dbName = string
    sslmode        = string
  })
  sensitive = true
}

variable "minio" {
  description = "Minio configurations"
  type = object({
    proxy_server = string
    server       = string
    user         = string
    pass         = string
  })
  sensitive = true
}

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
    mail       = "mail"
    monitoring = "monitoring"
    code       = "code"
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

variable "dns_server_ip" {
  type        = string
  description = "External DNS server IP"
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

variable "mail_db_config" {
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
  default = {
    "type" = "mysqli"
    "host" = ""
    "port" = 3306
    "name" = "mail"
    "user" = "mailer"
    "pass" = ""
  }
}

variable "postfix_admin_config" {
  type = object({
    encrypt  = string
    password = string
  })
  description = "Postfix admin configuration"
  sensitive   = true
}

variable "remote_smtp_options" {
  type = object({
    server = string
    port   = number
    user   = string
    pass   = string
  })
  sensitive   = true
  description = "Remote SMTP server options"
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

variable "code_server_ip" {
  type        = string
  description = "IP address of the code server"
}

variable "n8n_license_key" {
  description = "The n8n license key"
  type        = string
  sensitive   = true
}