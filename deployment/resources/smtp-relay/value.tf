variable "namespace" {
  description = "kubernetes namepsace to host smtp-relay"
  sensitive   = false
  type        = string
}

variable "cluster_domain" {
  type        = string
  description = "K8s cluster domain name"
  default     = "cluster.local"
}

variable "domain" {
  type        = string
  description = "Default Domain name cluster endpoint"
}

variable "image" {
  description = "SMTP RELAY image name"
  default     = "ramank775/smtp-relay"
  sensitive   = false
  type        = string
}

variable "tag" {
  description = "image tag"
  default     = "latest"
  sensitive   = false
  type        = string
}

variable "replicas" {
  type        = number
  description = "replica count"
  default     = 1
}

variable "smtp_relay_host" {
  description = "SMTP Relay server"
  type = string
}

variable "smtp_relay_user" {
  description = "SMTP Relay server username"
  type = string
}

variable "smtp_relay_pass" {
  description = "SMTP Relay sever password"
  type = string
  sensitive = true
}

variable "smtp_relay_networks" {
  description = "List of networks allow to send mail via relay"
  type = string
  default = "127.0.0.0/8 10.0.0.0/8"
}