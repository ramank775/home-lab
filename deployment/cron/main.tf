resource "kubernetes_namespace" "homelab_cron_namespace" {
  metadata {
    name = var.namespace
  }
}

module "public_ip_monitor" {
  source = "./public-ip-monitor"
  namespace = var.namespace
  nats_streaming_http_producer_url = var.nats_streaming_http_producer_url
}
