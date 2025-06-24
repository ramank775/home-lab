variable "replicas" {
  description = "Number of replicas for the application deployment."
  type        = number
  default     = 1
}

variable "namespace" {
  description = "The Kubernetes namespace where the application will be deployed."
  type        = string
  default     = "homelab-apps"
}

variable "domain" {
  description = "The domain name for the application."
  type        = string
  default     = "scrapper.homelab.arpa"
}

variable "llm_credentail_file" {
  description = "Path to the YAML file containing LLM credentials."
  type        = string
}
