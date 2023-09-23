# module "resources" {
#   source        = "./resources"
#   namespace     = var.namespaces.resources
#   replicas      = var.resources_replicas
#   node_selector = var.resources_node_selector
# }

module "apps" {
  source    = "./apps"
  namespace = var.namespaces.apps
  domain    = var.domain
  replicas  = var.apps_replicas
  //nats_url           = module.resources.nats.endpoint
  //nats_cluster_id    = module.resources.nats.cluster_id
  //slack_endpoint     = var.slack_endpoint
  tunnel_ssh_user              = var.tunnel_ssh_user
  tunnel_ssh_port              = var.tunnel_ssh_port
  tunnel_proxy_host            = var.tunnel_proxy_host
  tunnel_remote_port           = var.tunnel_remote_port
  tunnel_ssh_key               = var.tunnel_ssh_key
  node_selector                = var.apps_node_selector
  static_site_pass             = var.static_site_pass
  static_site_user             = var.static_site_user
  dovecot_config_dir           = var.dovecot_config_dir
  spampd_config_dir            = var.spampd_config_dir
  mail_db_type                 = var.mail_db_type
  mail_db_host                 = var.mail_db_host
  mail_db_port                 = var.mail_db_port
  mail_db_name                 = var.mail_db_name
  mail_db_user                 = var.mail_db_user
  mail_db_pass                 = var.mail_db_pass
  mail_smtp_port               = var.mail_smtp_port
  mail_smtp_server             = var.mail_smtp_server
  postfix_admin_setup_password = var.postfix_admin_setup_password
  postfix_admin_encrypt        = var.postfix_admin_encrypt
}

module "cron" {
  source                           = "./cron"
  namespace                        = var.namespaces.crons
  replicas                         = var.crons_replicas
  nats_streaming_http_producer_url = ""
  github_token                     = var.github_token
  node_selector                    = var.crons_node_selector
}
