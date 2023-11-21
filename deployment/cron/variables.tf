variable "namespace" {
  type        = string
  description = "Kubernetes namespace for apps"
  default     = "homelab-apps"
}

variable "replicas" {
  type        = map(number)
  description = "Replica count for crons"
  default = {
    public_ip_monitor  = 1
    blog_feature_posts = 1
  }
}

variable "node_selector" {
  type        = map(string)
  description = "Node selector for homelab Crons "
  default     = {}
}

variable "nats_streaming_http_producer_url" {
  type        = string
  description = "nats streaming http producer endpoint"
}

variable "github_token" {
  type        = string
  description = "github personal access token"
  sensitive   = true
}
