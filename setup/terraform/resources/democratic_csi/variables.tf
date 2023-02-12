variable "truenas_host" {
  type    = string
  default = "10.0.0.30"
}

variable "truenas_port" {
  type    = number
  default = 80
}

variable "truenas_apikey" {
  type      = string
  sensitive = false
}

variable "truenas_pool" {
  type    = string
  default = "pool-1"
}
