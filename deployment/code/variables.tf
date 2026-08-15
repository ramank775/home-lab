variable "namespace" {
  description = "Namespace to host code releted resources"
  default     = "code"
}

variable "default_storage_class" {
  description = "Default storage class name"
  default     = "truenas-iscsi-csi"
}

variable "forgejo_version" {
  description = "Helm chart version for foregjo"
  type        = string
}

variable "forgejo_runner_node_image" {
  description = "node docker image tag used for forgejo runner labels"
  type        = string
}

variable "forgejo_database" {
  description = "Database configuration for forgejo"
  type = object({
    type = string
    host = string
  })
}

variable "minio" {
  description = "Minio configuration (used for actions artifact storage)"
  type = object({
    proxy_server = string
    server       = string
    user         = string
    pass         = string
  })
  sensitive = true
}

variable "forgejo_ip" {
  description = "value of the forgejo ip"
  type        = string
}

variable "public_gateway_ip" {
  description = "IP of the public gateway that terminates TLS for public_host; used to map the runner's artifact upload to a reachable, cert-valid endpoint"
  type        = string
}

variable "public_host" {
  description = "Public host for forgejo"
  type        = string
}

variable "smtp" {
  description = "SMTP configuration for forgejo"
  type = object({
    host = string
    port = number
  })
}

variable "imap" {
  description = "IMAP configuration for forgejo"
  type = object({
    host = string
    port = number
  })
}

variable "email" {
  description = "Email configuration for forgejo"
  type = object({
    incoming = object({
      user    = optional(string)
      passwd  = optional(string)
      address = string
    })
    noreply = object({
      user    = optional(string)
      passwd  = optional(string)
      address = string
    })
  })
}

variable "node_name" {
  description = "Proxmox node to place the Forgejo Actions runner VM on."
  type        = string
}

variable "forgejo_runner_uuid" {
  description = "Forgejo runner UUID (passed from root)."
  type        = string
  sensitive   = true
}

variable "forgejo_runner_token" {
  description = "Forgejo runner per-runner token (passed from root)."
  type        = string
  sensitive   = true
}

variable "forgejo_runner_debian_password" {
  description = "Plain-text password for the `debian` user, baked into cloud-init user-data via chpasswd."
  type        = string
  sensitive   = true
}
