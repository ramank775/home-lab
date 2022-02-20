module "networking" {
  source = "./networking"
}
module "resources" {
  source    = "./resources"
  namespace = var.namespaces.resources
}

module "apps" {
  source             = "./apps"
  namespace          = var.namespaces.apps
  nats_url           = module.resources.nats.endpoint
  nats_cluster_id    = module.resources.nats.cluster_id
  slack_endpoint     = var.slack_endpoint
  tunnel_ssh_user    = var.tunnel_ssh_user
  tunnel_ssh_port    = var.tunnel_ssh_port
  tunnel_proxy_host  = var.tunnel_proxy_host
  tunnel_remote_port = var.tunnel_remote_port
  tunnel_ssh_key     = var.tunnel_ssh_key
}

module "cron" {
  source                           = "./cron"
  namespace                        = var.namespaces.crons
  nats_streaming_http_producer_url = module.apps.nats_streaming_http_producer.endpoint
  github_token                     = var.github_token
}
