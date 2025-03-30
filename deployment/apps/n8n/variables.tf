variable "namespace" {
  description = "The namespace in which to deploy n8n"
  type        = string
  default     = "n8n"  
}

variable "domain" {
  description = "The domain name for n8n"
  type        = string
  default     = "n8n.homelab.arpa"
}

variable "storage_class" {
  description = "The storage class to use for n8n"
  type        = string
  default     = "truenas-iscsi-csi"
}

variable "helm_version" {
  description = "The version of n8n to deploy"
  type        = string
  default     = "1.5.3"
}

variable "image_tag" {
  description = "The image tag for n8n"
  type        = string
  default     = "1.84.3"
  
}

variable "database" {
  description = "The database connection details"
  type = object({
    host = string
    port = number
  })
}

variable "minio" {
  description = "values for minio"
  type = object({
    server = string
  })
}

variable "n8n_license_key" {
  description = "The n8n license key"
  type        = string
  sensitive   = true
}
