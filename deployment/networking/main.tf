module "metallb" {
  source    = "./metallb"
  namespace = var.namespaces.metallb
  iprange   = var.lb_iprange
}
