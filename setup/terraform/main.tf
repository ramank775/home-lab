module "resources" {
  source        = "./resources"
  namespace     = var.namespace
  node_selector = var.node_selector
  domain        = var.domain
  versions      = var.versions
  truenas       = var.truenas
  lb_iprange    = var.lb_iprange
}
