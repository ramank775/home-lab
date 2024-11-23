resource "kubernetes_namespace" "homelab_resources_namespace" {
  metadata {
    name = var.namespace
  }
}

# module "longhorn" {
#   source = "./longhorn"
#   version = var.versions.longhorn
#   domain = "longhorn.${var.domain}"
# }

module "metallb" {
  source        = "./metallb"
  iprange       = var.lb_iprange
  chart_version = var.versions.metallb
}

module "traefik" {
  source = "./traefik"
  domain = "traefix.${var.domain}"
}

module "democratic" {
  source         = "./democratic_csi"
  chart_version  = var.versions.democratic_csi
  truenas_host   = var.truenas.host
  truenas_port   = var.truenas.port
  truenas_pool   = var.truenas.pool
  truenas_apikey = var.truenas.apikey
}

module "system-updater" {
  source = "./system_updater"
}
