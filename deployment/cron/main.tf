resource "kubernetes_namespace" "homelab_cron_namespace" {
  metadata {
    name = var.namespace
  }
}

module "public_ip_monitor" {
  source                           = "./public-ip-monitor"
  namespace                        = var.namespace
  nats_streaming_http_producer_url = var.nats_streaming_http_producer_url
  node_selector                    = var.node_selector
}

module "blog_feature_posts" {
  source                           = "./blog-feature-posts"
  namespace                        = var.namespace
  github_token                     = var.github_token
  nats_streaming_http_producer_url = var.nats_streaming_http_producer_url
  node_selector                    = var.node_selector
}
