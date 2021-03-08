module "resources" {
  source    = "./resources"
  namespace = var.namespaces.resources
}

module "apps" {
  source          = "./apps"
  namespace       = var.namespaces.apps
  nats_url        = module.resources.nats.endpoint
  nats_cluster_id = module.resources.nats.cluster_id
  slack_endpoint  = var.slack_endpoint
}

module "cron" {
  source                           = "./cron"
  namespace                        = var.namespaces.crons
  nats_streaming_http_producer_url = module.apps.nats_streaming_http_producer.endpoint
}
