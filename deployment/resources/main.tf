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

module "cloudflared" {
  source                  = "./cloudflared"
  namespace               = var.namespace
  node_selector           = var.node_selector
  cloudflared_cred_file   = var.cloudflared_cred_file
  cloudflared_config_file = var.cloudflared_config_file
  cloudflared_cert_file   = var.cloudflared_cert_file
}

