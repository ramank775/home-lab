variable "namespaces" {
  type        = map(string)
  description = "Namespace for different resources"
  default = {
    apps      = "homelab-apps"
    crons     = "homelab-crons"
    resources = "homelab-resources"
  }
}
