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
  default     = "v1.2.0"
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

variable "md5_key" {
  type        = string
  description = "Secret key for page ID hashing"
  sensitive   = true
}

variable "admin_api_key" {
  type        = string
  description = "API key for admin endpoints"
  sensitive   = true
  default     = ""
}

variable "backup_image" {
  type        = string
  description = "Backup sidecar image name"
  default     = "ramank775/visitor-badge-backup"
}

variable "backup_tag" {
  type        = string
  description = "Backup sidecar image tag"
  default     = "v1.2.0"
}
