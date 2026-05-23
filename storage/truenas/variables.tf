variable "truenas_url" {
  description = "TrueNAS web UI URL, e.g. https://10.0.0.30"
  type        = string
}

variable "truenas_api_key" {
  description = "TrueNAS API key (UI → user icon → API Keys → Add)."
  type        = string
  sensitive   = true
}

variable "truenas_allow_insecure" {
  description = "Skip TLS verification (true for self-signed TrueNAS certs)."
  type        = bool
  default     = true
}

variable "wp_serverless_share_hosts" {
  description = "Allowed hosts for the wp-serverless NFS share."
  type        = list(string)
  default     = []
}
