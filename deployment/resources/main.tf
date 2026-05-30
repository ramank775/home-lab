# module "nats" {
#   source        = "./nats"
#   namespace     = var.namespace
#   node_selector = var.node_selector
#   replicas      = var.replicas.nats
# }

module "bind9" {
  source      = "./bind9"
  namespace   = var.namespace
  external_ip = var.dns_server_ip
  image_tag   = var.bind9_image_tag
}

module "smtp-relay" {
  source          = "./smtp-relay"
  namespace       = var.namespace
  replicas        = var.replicas.smtp_relay
  domain          = var.domain
  cluster_domain  = var.cluster_domain
  smtp_relay_host = var.smtp_relay_host
  smtp_relay_user = var.smtp_relay_user
  smtp_relay_pass = var.smtp_relay_pass
  tag             = var.smtp_relay_image_tag
}

module "pihole" {
  source            = "./pihole"
  namespace         = var.namespace
  domain            = "pihole.${var.domain}"
  node_selector     = var.node_selector
  replicas          = 1
  pihole_config_dir = var.pihole_config_dir
  tag               = var.pihole_image_tag
}

module "cloudflared" {
  source                  = "./cloudflared"
  namespace               = var.namespace
  node_selector           = var.node_selector
  replicas                = 1
  cloudflared_cred_file   = var.cloudflared.cred_file
  cloudflared_config_file = var.cloudflared.config_file
  cloudflared_cert_file   = var.cloudflared.cert_file
  tag                     = var.cloudflared_image_tag
}

module "headlamp" {
  source        = "./headlamp"
  domain        = "kube.${var.domain}"
  chart_version = var.headlamp_chart_version
}

module "temporal" {
  source                  = "./temporal"
  namespace               = var.namespace
  domain                  = var.domain
  database                = var.shared_db
  server_image_tag        = var.temporal_server_image_tag
  ui_image_tag            = var.temporal_ui_image_tag
  elasticsearch_image_tag = var.elasticsearch_image_tag
}
