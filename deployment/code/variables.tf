variable "namespace" {
  description = "Namespace to host code releted resources"
  default     = "code"
}

variable "default_storage_class" {
  description = "Default storage class name"
  default     = "truenas-iscsi-csi"
}

variable "forgejo_version" {
  description = "Helm chart version for foregjo"
  default     = "11.0.5"
}

variable "forgejo_database" {
  description = "Database configuration for forgejo"
  type = object({
    type   = string
    host   = string
  })
}

variable "forgejo_ip" {
  description = "value of the forgejo ip"
  type        = string
}