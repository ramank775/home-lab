variable "iprange" {
  type        = string
  description = "metallb ip range"
  default     = "192.168.0.240-192.168.0.250"
}

variable "chart_version" {
  type    = string
  default = "0.14.8"
}
