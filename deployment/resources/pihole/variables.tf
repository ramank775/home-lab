variable "namespace" {
  description = "kubernetes namepsace to host pihole"
  sensitive   = false
  type        = string
}

variable "node_selector" {
  type        = map(string)
  description = "Node Selector for pihole"
  default     = {}
}

variable "replicas" {
  type        = number
  description = "PiHole replica count"
  default     = 1
}

variable "image" {
  description = "Pihole image name"
  default     = "pihole/pihole"
  sensitive   = false
  type        = string
}

variable "tag" {
  description = "pihole image tag"
  default     = "2022.04.2"
  sensitive   = false
  type        = string
}

variable "admin_pass" {
  type        = string
  description = "Web admin portal password"
  sensitive   = true
  default     = "thisispassword"
}

variable "tz" {
  type        = string
  description = "timezone for pihole server"
  default     = "ASIA/KOLKATA"
}

variable "upstream_dns" {
  type        = string
  description = "upstream dns server seperated by ';'"
  default     = "208.67.222.222;208.67.220.220"
}
