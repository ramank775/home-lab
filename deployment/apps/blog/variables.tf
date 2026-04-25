variable "namespace" {
  type        = string
  description = "Kubernetes namespace for apps"
  default     = "homelab-apps"
}

variable "domain" {
  type        = string
  description = "Default Domain name cluster endpoint"
}

variable "nats_streaming_http_producer_url" {
  type        = string
  description = "nats streaming http producer url"
}

variable "github_config" {
  type        = map(string)
  sensitive   = true
  description = "github configurations"
}

variable "node_selector" {
  type        = map(string)
  description = "Node selector for blog feature posts"
  default     = {}
}

variable "feature_post_image_tag" {
  type        = string
  description = "Image tag for blog feature post cron"
}

variable "oauth_provider_image_tag" {
  type        = string
  description = "Image tag for netlify-cms OAuth provider"
}