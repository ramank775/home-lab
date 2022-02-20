
variable "namespace" {
  type        = string
  description = "kubernetes namepsace for tcp tunnel client"
  default     = "homelab_apps"
}

variable "image" {
  type        = string
  description = "tcp tunnel client image name"
  default     = "ramank775/tunnel-client"
}

variable "tag" {
  description = "TCP tunnel client image tag"
  default     = "v0.0.3"
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
  description = "SSH private key of proxy server"
}
