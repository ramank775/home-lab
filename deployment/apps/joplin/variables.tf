variable "namespace" {
  description = "The namespace to deploy the application in"
  type        = string
  default     = "homelab-apps"
}

variable "replicas" {
  description = "The number of replicas for the application"
  type        = number
  default     = 1
}

variable "image_repo" {
  description = "The Docker image for the application"
  type        = string
  default     = "joplin/server"
}

variable "image_tag" {
  description = "The Docker image tag for the application"
  type        = string
}

variable "database" {
  description = "The database to use for the application"
  type = object({
    host = string
    port = number
  })
}

variable "smtp" {
  description = "The SMTP server to use for the application"
  type = object({
    host     = string
    port     = number
    security = optional(string)
  })
}

variable "email" {
  description = "Sender identity for outbound email"
  type = object({
    from_name    = string
    from_address = string
    reply_to     = optional(string)
  })
}

variable "domain" {
  description = "The public hostname for the application (no scheme)"
  type        = string
}
