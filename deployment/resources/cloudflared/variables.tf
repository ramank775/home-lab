
variable "namespace" {
  type        = string
  description = "kubernetes namepsace for cloudflared tunnel client"
}

variable "node_selector" {
  type        = map(string)
  description = "Node selector for cloudflared tunnel client"
  default     = {}
}

variable "replicas" {
  type        = number
  description = "Replica count for cloudflared tunnel client"
  default     = 1
}

variable "image" {
  type        = string
  description = "clouldflared tunnel client image name"
  default     = "cloudflare/cloudflared"
}

variable "tag" {
  description = "TCP tunnel client image tag"
  default     = "2023.10.0"
  sensitive   = false
  type        = string
}

variable "memorylimit" {
  description = "Memory resource limit for nats pod"
  default     = "120Mi"
  sensitive   = false
  type        = string
}

variable "cloudflared_cert_file" {
  type        = string
  description = "Cloudflared tunnel cert file"
}

variable "cloudflared_cred_file" {
  type        = string
  description = "Cloudflared tunnel cred file path"
}

variable "cloudflared_config_file" {
  type        = string
  description = "Cloudflared config file"
}

