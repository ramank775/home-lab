variable "cluster_domain" {
  type        = string
  description = "K8s cluster domain name"
  default     = "cluster.local"
}

variable "namespace" {
  type        = string
  description = "kubernetes namepsace to host nats streaming http producer"
  default     = "homelab_apps"
}

variable "image" {
  type        = string
  description = "Nats streaming http producer image name"
  default     = "ramank775/home_lab_nats_streaming_http_producer"
}

variable "tag" {
  description = "Nats streaming image tag"
  default     = "v1.0"
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
  default     = "http-producer"
}
