variable "replicas" {
  type        = number
  description = "PiHole replica count"
  default     = 1
}

variable "namespace" {
  description = "kubernetes namepsace to host pihole"
  sensitive   = false
  type        = string
}

variable "image" {
  description = "Pihole image name"
  default     = "pihole/pihole"
  sensitive   = false
  type        = string
}

variable "tag" {
  description = "pihole image tag"
  default     = "latest"
  sensitive   = false
  type        = string
}