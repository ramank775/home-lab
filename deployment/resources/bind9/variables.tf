variable "namespace" {
  type        = string
  description = "kubernetes namepsace to host bind9 dns server"
}

variable "external_ip" {
  type        = string
  description = "External IP for bind9 dns server"
}
