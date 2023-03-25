variable "namespace" {
  type        = string
  description = "kubernetes namepsace to host static website"
  default     = "homelab_apps"
}

variable "username" {
  type        = string
  description = "static server ssh username"
  default     = "myuser"
}

variable "password" {
  type        = string
  description = "static server ssh password"
  sensitive   = true
}
