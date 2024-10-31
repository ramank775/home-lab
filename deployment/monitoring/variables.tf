variable "namespace" {
  type        = string
  description = "Namespace for monitoring resources"
  default     = "monitoring"
}

variable "domain" {
  type        = string
  description = "Internal service domain"
  default     = "monitoring.homelab.arpa"
}

variable "storageClassName" {
  type        = string
  description = "Persistence storage class name"
  default     = "truenas-iscsi-csi"
}

variable "external_ips" {
  type        = map(string)
  description = "External IP for monitoring Stack for ingress"
}

variable "config_dir" {
  type        = string
  description = "Directory contains configuration files for monitoring"

}
