
variable "namespace" {
  type        = string
  description = "kubernetes namepsace for cloudflared tunnel client"
}

variable "image" {
  type        = string
  description = "clouldflared tunnel client image name"
  default     = "erisamoe/cloudflared"
}

variable "tag" {
  description = "TCP tunnel client image tag"
  default     = "2022.4.1"
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

variable "node_selector" {
  type        = map(string)
  description = "Node selector for tcp tunnel client"
  default     = {}
}
