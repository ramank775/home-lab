variable "namespace" {
  description = "Kubernetes namespace to deploy CloudBeaver in"
  type        = string
}

variable "domain" {
  description = "Public hostname for CloudBeaver ingress"
  type        = string
}

variable "image_repo" {
  description = "Container image repository for CloudBeaver"
  type        = string
  default     = "dbeaver/cloudbeaver"
}

variable "image_tag" {
  description = "Container image tag for CloudBeaver"
  type        = string
}

variable "storage_size" {
  description = "Size of the workspace PVC"
  type        = string
  default     = "5Gi"
}

variable "storage_class" {
  description = "StorageClass for the workspace PVC"
  type        = string
  default     = "truenas-iscsi-csi"
}
