variable "namespace" {
  description = "The namespace where the SearxNG application will be deployed."
  type        = string
  default     = "searxng" 
}

variable "domain" {
  description = "The domain name for the SearxNG application."
  type        = string
  default     = "search.homelab.arpa"
}

variable "chart_version" {
  description = "The version of the SearxNG Helm chart to deploy."
  type        = string
  default     = "1.0.7"
}