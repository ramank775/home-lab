variable "namespace" {
  type        = string
  description = "kubernetes namepsace to host blog feature post"
  default     = "homelab_apps"
}

variable "image" {
  type        = string
  description = "blog feature post image name"
  default     = "ramank775/blog_feature_post"
}

variable "tag" {
  description = "blog feature post image tag"
  default     = "v1.0.2"
  sensitive   = false
  type        = string
}

variable "github_token" {
  type        = string
  sensitive   = true
  description = "github personal access token"
}

variable "nats_streaming_http_producer_url" {
  type        = string
  description = "nats streaming http producer url"
}
