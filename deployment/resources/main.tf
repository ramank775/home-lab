resource "kubernetes_namespace" "homelab_resources_namespace" {
  metadata {
    name = var.namespace
  }
}

module "nats" {
  source    = "./nats"
  namespace = var.namespace
}

module "pihole" {
  source    = "./pihole"
  namespace = var.namespace
}
