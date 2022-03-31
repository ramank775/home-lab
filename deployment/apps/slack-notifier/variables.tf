variable "namespace" {
  type        = string
  description = "kubernetes namepsace to host slack notifier"
  default     = "homelab_apps"
}

variable "node_selector" {
  type        = map(string)
  description = "Node selector for slack notifier"
  default     = {}
}

variable "image" {
  type        = string
  description = "slack notifier image name"
  default     = "ramank775/home_lab_slack-notifier"
}

variable "tag" {
  description = "Slack notifier image tag"
  default     = "v1.0.1"
  sensitive   = false
  type        = string
}

variable "replicas" {
  type        = number
  description = "Replica count"
  default     = 1
}

variable "memorylimit" {
  description = "Memory resource limit for nats pod"
  default     = "120Mi"
  sensitive   = false
  type        = string
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

variable "client_id" {
  type        = string
  description = "Nats client id"
  default     = "slack-notifier"
}

variable "slack_endpoint" {
  type        = string
  description = "Slack webhook endpoint"
}
