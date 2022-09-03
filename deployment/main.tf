module "networking" {
  source     = "./networking"
  lb_iprange = var.lb_iprange
}
module "resources" {
  source                  = "./resources"
  namespace               = var.namespaces.resources
  domain                  = var.domain
  replicas                = var.resources_replicas
  cloudflared_cred_file   = var.cloudflared_cred_file
  cloudflared_config_file = var.cloudflared_config_file
  cloudflared_cert_file   = var.cloudflared_cert_file
  node_selector           = var.resources_node_selector
  pihole_config_dir       = var.pihole_config_dir
}

module "apps" {
  source             = "./apps"
  namespace          = var.namespaces.apps
  domain             = var.domain
  replicas           = var.apps_replicas
  nats_url           = module.resources.nats.endpoint
  nats_cluster_id    = module.resources.nats.cluster_id
  slack_endpoint     = var.slack_endpoint
  tunnel_ssh_user    = var.tunnel_ssh_user
  tunnel_ssh_port    = var.tunnel_ssh_port
  tunnel_proxy_host  = var.tunnel_proxy_host
  tunnel_remote_port = var.tunnel_remote_port
  tunnel_ssh_key     = var.tunnel_ssh_key
  node_selector      = var.apps_node_selector
}

module "cron" {
  source                           = "./cron"
  namespace                        = var.namespaces.crons
  replicas                         = var.crons_replicas
  nats_streaming_http_producer_url = module.apps.nats_streaming_http_producer.endpoint
  github_token                     = var.github_token
  node_selector                    = var.crons_node_selector
}
