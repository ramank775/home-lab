variable "cluster_domain" {
  type        = string
  description = "K8s cluster domain name"
  default     = "cluster.local"
}

variable "namespace" {
  description = "kubernetes namepsace to host nats"
  sensitive   = false
  type        = string
}

variable "replicas" {
  type        = number
  description = "Nats replica count"
  default     = 1
}

variable "image" {
  description = "Nats streaming image name"
  default     = "nats-streaming"
  sensitive   = false
  type        = string
}

variable "tag" {
  description = "Nats streaming image tag"
  default     = "0.21.1-scratch"
  sensitive   = false
  type        = string
}

variable "memorylimit" {
  description = "Memory resource limit for nats pod"
  default     = "120Mi"
  sensitive   = false
  type        = string
}

variable "clusterid" {
  description = "Nats streaming cluster id"
  default     = "home-lab"
  sensitive   = false
  type        = string
}

variable "node_selector" {
  type        = map(string)
  description = "Node selector for nats "
  default     = {}
}
