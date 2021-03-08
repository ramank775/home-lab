resource "kubernetes_namespace" "homelab_apps_namespace" {
  metadata {
    name = var.namespace
  }
}

module "nats_streaming_http_producer" {
  source          = "./nats-streaming-http-producer"
  namespace       = var.namespace
  replicas        = 1
  nats_url        = var.nats_url
  nats_cluster_id = var.nats_cluster_id
}

module "slack-notifier" {
  source          = "./slack-notifier"
  namespace       = var.namespace
  replicas        = 1
  nats_url        = var.nats_url
  nats_cluster_id = var.nats_cluster_id
  slack_endpoint  = var.slack_endpoint
}
