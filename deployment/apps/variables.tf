variable "namespace" {
  type        = string
  description = "Kubernetes namespace for apps"
  default     = "homelab-apps"
}

variable "node_selector" {
  type        = map(string)
  description = "Node selector for homelab apps "
  default     = {}
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
  type        = string
  description = "Slack webhook endpoint"
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

