module "metallb" {
  source  = "./metallb"
  iprange = var.lb_iprange
}

module "pihole" {
  source            = "./pihole"
  namespace         = var.namespace
  domain            = "pihole.${var.domain}"
  node_selector     = var.node_selector
  replicas          = 1
  pihole_config_dir = var.pihole_config_dir
}

module "kube-dashboard" {
  source = "./kube_dashboard"
}

# module "system_updater" {
#   source = "./system_upgrade"
# }
