variable "namespace" {
    type = string
    description = "Kubernetes namespace for apps"
    default = "homelab-apps"
}

variable "nats_url" {
  type        = string
  description = "Nats cluster url"
}

variable "nats_cluster_id" {
  type        = string
  description = "Nats cluster id"
  default     = "home-lab"
}

variable "slack_endpoint" {
  type = string
  description = "Slack webhook endpoint"
}