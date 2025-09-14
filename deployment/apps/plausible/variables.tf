variable "namespace" {
  description = "The namespace in which to deploy Plausible."
  type        = string
  default     = "plausible"  
}

variable "plausible_version" {
  description = "The version of Plausible to deploy."
  type        = string
  default     = "v3.0.1" 
}

variable "replicas" {
  description = "The number of replicas for the Plausible deployment."
  type        = number
  default     = 1  
}

variable "base_url" {
  description = "The base URL for the Plausible instance."
  type        = string
  default     = "https://plausible.example.com"
}

variable "clickhouse" {
  description = "ClickHouse connection details."
  type = object({
    url = string
  })
  default = {
    url = "http://clickhouse.example.com:8123"
  }
}

variable "postgresql" {
  description = "PostgreSQL connection details."
  type = object({
    host = string
    port = number
  })
  default = {
    host = "postgresql.example.com"
    port = 5432
  }
}


variable "mailer" {
  description = "Mailer configuration for Plausible."
  type = object({
    name     = string
    email     = string
  })
  default = {
    name  = "Plausible Analytics"
    email = "plausible@example.com"
  }
  
}

variable "smtp_options" {
  type        = map(string)
  description = "smtp settings"
  default = {
    "host"     = "mail.homelab.arpa"
    "port"     = 25
    "security" = "off"
  }
}

variable "google_oauth_credentials_file_path" {
  description = "Path to the Google OAuth credentials file."
  type        = string
}