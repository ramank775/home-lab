resource "kubernetes_namespace" "homelab_resources_namespace" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_storage_class_v1" "hyper_converged" {
  metadata {
    name = "hyper-converged"
  }
  storage_provisioner    = "driver.longhorn.io"
  allow_volume_expansion = true
  parameters = {
    numberOfReplicas    = "2"
    dataLocality        = "best-effort"
    staleReplicaTimeout = "2880"
    fromBackup          = ""
  }
}

module "nats" {
  source        = "./nats"
  namespace     = var.namespace
  node_selector = var.node_selector
  replicas      = var.replicas.nats
}

module "pihole" {
  source        = "./pihole"
  namespace     = var.namespace
  node_selector = var.node_selector
  replicas      = var.replicas.pihole
}

module "cloudflared" {
  source                  = "./cloudflared"
  namespace               = var.namespace
  node_selector           = var.node_selector
  replicas                = var.replicas.cloudflared
  cloudflared_cred_file   = var.cloudflared_cred_file
  cloudflared_config_file = var.cloudflared_config_file
  cloudflared_cert_file   = var.cloudflared_cert_file
}

