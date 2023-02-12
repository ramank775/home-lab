resource "kubernetes_namespace" "homelab_resources_namespace" {
  metadata {
    name = var.namespace
  }
}

# module "longhorn" {
#   source = "./longhorn"
#   domain = "longhorn.${var.domain}"
# }

module "metallb" {
  source = "./metallb"
}


module "kube-dashboard" {
  source       = "./kube_dashboard"
  domain       = "kube.${var.domain}"
  dash_version = var.versions.kube_dash
}

module "traefik" {
  source = "./traefik"
  domain = "traefix.${var.domain}"
}

module "democratic" {
  source         = "./democratic_csi"
  truenas_host   = var.truenas.host
  truenas_port   = var.truenas.port
  truenas_pool   = var.truenas.pool
  truenas_apikey = var.truenas.apikey
}

# module "system-updater" {
#   source = "./system_updater"
# }

module "cloudflared" {
  source                  = "./cloudflared"
  namespace               = var.namespace
  node_selector           = var.node_selector
  replicas                = 1
  cloudflared_cred_file   = var.cloudflared.cred_file
  cloudflared_config_file = var.cloudflared.config_file
  cloudflared_cert_file   = var.cloudflared.cert_file
}
