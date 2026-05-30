variable "namespace" {
  description = "Namespace to deploy Temporal stack into"
  type        = string
}

variable "domain" {
  description = "Base domain; Temporal UI is exposed at temporal.<domain>"
  type        = string
}

variable "database" {
  description = "Shared LXC Postgres host/port. Temporal owns its temporal/temporal_visibility DBs but the role/DBs are created by Terraform, not auto-setup."
  type = object({
    host = string
    port = number
  })
}

variable "server_image_tag" {
  description = "Tag for temporalio/auto-setup"
  type        = string
}

variable "ui_image_tag" {
  description = "Tag for temporalio/ui"
  type        = string
}

variable "elasticsearch_image_tag" {
  description = "Tag for elasticsearch (v7 line). Temporal v1.28 requires ES v7 visibility."
  type        = string
}

variable "elasticsearch_storage_size" {
  description = "PVC size for Elasticsearch indices"
  type        = string
  default     = "5Gi"
}

variable "storage_class" {
  description = "StorageClass for Elasticsearch PVC"
  type        = string
  default     = "truenas-iscsi-csi"
}
