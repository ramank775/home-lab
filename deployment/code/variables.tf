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
  default     = "13.0.1"
}

variable "forgejo_database" {
  description = "Database configuration for forgejo"
  type = object({
    type = string
    host = string
  })
}

variable "forgejo_ip" {
  description = "value of the forgejo ip"
  type        = string
}

variable "public_host" {
  description = "Public host for forgejo"
  type        = string
}

variable "smtp" {
  description = "SMTP configuration for forgejo"
  type = object({
    host = string
    port = number
  })
}

variable "imap" {
  description = "IMAP configuration for forgejo"
  type = object({
    host = string
    port = number
  })
}

variable "email" {
  description = "Email configuration for forgejo"
  type = object({
    incoming = object({
      user    = optional(string)
      passwd  = optional(string)
      address = string
    })
    noreply = object({
      user    = optional(string)
      passwd  = optional(string)
      address = string
    })
  })
}
