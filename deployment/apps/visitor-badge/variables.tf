variable "cluster_domain" {
  type        = string
  description = "K8s cluster domain name"
  default     = "cluster.local"
}

variable "namespace" {
  type        = string
  description = "kubernetes namepsace for visitor apps client"
  default     = "homelab_apps"
}

variable "image" {
  type        = string
  description = "Visitor badge image name"
  default     = "ramank775/visitor-badge"
}

variable "tag" {
  description = "Visitor badge image tag"
  default     = "v1.1.0"
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
  default     = "512Mi"
  sensitive   = false
  type        = string
}

variable "node_selector" {
  type        = map(string)
  description = "Node selector for tcp tunnel client"
  default     = {}
}
