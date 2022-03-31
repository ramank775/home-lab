resource "kubernetes_namespace" "homelab_resources_namespace" {
  metadata {
    name = var.namespace
  }
}

module "nats" {
  source        = "./nats"
  namespace     = var.namespace
  node_selector = var.node_selector
}

module "pihole" {
  source        = "./pihole"
  namespace     = var.namespace
  node_selector = var.node_selector
}
