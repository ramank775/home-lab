variable "namespace" {
    type = string
    description = "Kubernetes namespace for apps"
    default = "homelab-apps"
}

variable "nats_streaming_http_producer_url" {
    type = string
    description = "nats streaming http producer endpoint"
}