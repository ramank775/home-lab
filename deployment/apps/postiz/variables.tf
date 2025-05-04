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
  default     = "ghcr.io/gitroomhq/postiz-app"
}

variable "image_tag" {
  description = "The Docker image tag for the application"
  type        = string
  default     = "v1.41.1"

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
  description = "The email address to use for the application"
  type = object({
    user    = string
    pass    = string
    address = string
  })
}

variable "domain" {
  description = "The public URL for the application"
  type        = string
  default     = "https://postiz.homelab.arpa"
}

variable "social_app_config" {
  description = "Path to file with social app configuration"
  type        = string
}
