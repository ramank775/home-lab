module "resources" {
  source            = "./resources"
  namespace         = var.namespaces.resources
  replicas          = var.resources_replicas
  node_selector     = var.resources_node_selector
  domain            = var.domain
  smtp_relay_host   = "[${var.remote_smtp_options.server}]:${var.remote_smtp_options.port}"
  smtp_relay_user   = var.remote_smtp_options.user
  smtp_relay_pass   = var.remote_smtp_options.pass
  pihole_config_dir = var.pihole_config_dir
  cloudflared       = var.cloudflared
  dns_server_ip     = var.dns_server_ip
}

module "apps" {
  source    = "./apps"
  namespace = var.namespaces.apps
  domain    = var.domain
  replicas  = var.apps_replicas
  //nats_url           = module.resources.nats.endpoint
  //nats_cluster_id    = module.resources.nats.cluster_id
  //slack_endpoint     = var.slack_endpoint
  # tunnel_ssh_user                  = var.tunnel_ssh_user
  # tunnel_ssh_port                  = var.tunnel_ssh_port
  # tunnel_proxy_host                = var.tunnel_proxy_host
  # tunnel_remote_port               = var.tunnel_remote_port
  # tunnel_ssh_key                   = var.tunnel_ssh_key
  node_selector    = var.apps_node_selector
  static_site_pass = var.static_site_pass
  static_site_user = var.static_site_user
  # dovecot_config_dir               = var.dovecot_config_dir
  # spampd_config_dir                = var.spampd_config_dir
  # mail_db_type                     = var.mail_db_type
  # mail_db_host                     = var.mail_db_host
  # mail_db_port                     = var.mail_db_port
  # mail_db_name                     = var.mail_db_name
  # mail_db_user                     = var.mail_db_user
  # mail_db_pass                     = var.mail_db_pass
  # mail_dns_server                  = var.mail_dns_server
  # postfix_admin_setup_password     = var.postfix_admin_setup_password
  # postfix_admin_encrypt            = var.postfix_admin_encrypt
  vaultwarden_options              = var.vaultwarden_options
  smtp_options                     = module.resources.smtp_options
  blog_domain                      = var.blog_domain
  github_config                    = var.github_config
  nats_streaming_http_producer_url = ""

}

# module "cron" {
#   source                           = "./cron"
#   namespace                        = var.namespaces.crons
#   replicas                         = var.crons_replicas
#   nats_streaming_http_producer_url = ""
#   github_token                     = var.github_token
#   node_selector                    = var.crons_node_selector
# }

module "media" {
  source        = "./media"
  media_storage = var.media_storage
  namespace     = var.namespaces.media
  domains = {
    "media-mgmt" = "media-mgmt.${var.domain}"
    "prowlarr"   = "tracker.${var.domain}"
    "jellyseerr" = "jellyseerr.${var.domain}"
  }
}

module "mail" {
  source               = "./mail"
  namespace            = var.namespaces.mail
  dovecot_config_dir   = var.dovecot_config_dir
  spampd_config_dir    = var.spampd_config_dir
  dns_server           = var.dns_server_ip
  db_config            = var.mail_db_config
  smtp_options         = module.resources.smtp_options
  domain               = "mail.${var.domain}"
  postfix_admin_config = var.postfix_admin_config
}

module "code" {
  source    = "./code"
  namespace = var.namespaces.code
  forgejo_database = {
    type   = var.shared_db.type
    host   = var.shared_db.host
  }
  forgejo_ip = var.code_server_ip
}

module "monitoring" {
  source       = "./monitoring"
  namespace    = var.namespaces.monitoring
  domain       = "monitoring.${var.domain}"
  external_ips = var.monitroing_external_ips
  config_dir   = var.monitoring_config_dir
}
