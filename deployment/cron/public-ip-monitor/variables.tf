variable "namespace" {
  type        = string
  description = "kubernetes namepsace to host slack notifier"
  default     = "homelab_apps"
}

variable "image" {
  type        = string
  description = "slack notifier image name"
  default     = "ramank775/home_lab_public_ip_monitor"
}

variable "tag" {
  description = "Slack notifier image tag"
  default     = "v1.0.4"
  sensitive   = false
  type        = string
}

variable "nats_streaming_http_producer_url" {
  type        = string
  description = "nats streaming http producer url"
}

variable "node_selector" {
  type        = map(string)
  description = "Node selector for public ip monitor"
  default     = {}
}
