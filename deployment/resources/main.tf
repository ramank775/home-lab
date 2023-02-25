module "nats" {
  source        = "./nats"
  namespace     = var.namespace
  node_selector = var.node_selector
  replicas      = var.replicas.nats
}
