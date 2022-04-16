resource "kubernetes_namespace" "homelab_apps_namespace" {
  metadata {
    name = var.namespace
  }
}

module "nats_streaming_http_producer" {
  source          = "./nats-streaming-http-producer"
  namespace       = var.namespace
  replicas        = var.replicas.nats_streaming_http_producer
  nats_url        = var.nats_url
  nats_cluster_id = var.nats_cluster_id
  node_selector   = var.node_selector
}

module "slack_notifier" {
  source          = "./slack-notifier"
  namespace       = var.namespace
  replicas        = var.replicas.slack_notifier
  nats_url        = var.nats_url
  nats_cluster_id = var.nats_cluster_id
  slack_endpoint  = var.slack_endpoint
  node_selector   = var.node_selector
}

module "tunnel_client" {
  source             = "./tunnel-client"
  namespace          = var.namespace
  replicas           = var.replicas.tunnel_client
  tunnel_ssh_user    = var.tunnel_ssh_user
  tunnel_ssh_port    = var.tunnel_ssh_port
  tunnel_ssh_key     = var.tunnel_ssh_key
  tunnel_proxy_host  = var.tunnel_proxy_host
  tunnel_remote_port = var.tunnel_remote_port
  node_selector      = var.node_selector
}

module "visitor_badge" {
  source        = "./visitor-badge"
  namespace     = var.namespace
  replicas      = var.replicas.visitor_badge
  node_selector = var.node_selector
}
