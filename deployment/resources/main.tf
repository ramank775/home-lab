# module "nats" {
#   source        = "./nats"
#   namespace     = var.namespace
#   node_selector = var.node_selector
#   replicas      = var.replicas.nats
# }

module "smtp-relay" {
  source          = "./smtp-relay"
  namespace       = var.namespace
  replicas        = var.replicas.smtp_relay
  domain          = var.domain
  cluster_domain  = var.cluster_domain
  smtp_relay_host = var.smtp_relay_host
  smtp_relay_user = var.smtp_relay_user
  smtp_relay_pass = var.smtp_relay_pass
}
