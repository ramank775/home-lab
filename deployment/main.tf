module "resources" {
  source                             = "./resources"
  namespace                          = var.namespaces.resources
  replicas                           = var.resources_replicas
  node_selector                      = var.resources_node_selector
  domain                             = var.domain
  smtp_relay_host                    = "[${var.remote_smtp_options.server}]:${var.remote_smtp_options.port}"
  smtp_relay_user                    = var.remote_smtp_options.user
  smtp_relay_pass                    = var.remote_smtp_options.pass
  pihole_config_dir                  = var.pihole_config_dir
  cloudflared                        = var.cloudflared
  dns_server_ip                      = var.dns_server_ip
  kubernetes_dashboard_chart_version = local.versions.charts.kubernetes_dashboard
  bind9_image_tag                    = local.versions.images.bind9
  cloudflared_image_tag              = local.versions.images.cloudflared
  smtp_relay_image_tag               = local.versions.images.smtp_relay
  pihole_image_tag                   = local.versions.images.pihole
}

module "apps" {
  source                           = "./apps"
  namespace                        = var.namespaces.apps
  domain                           = var.domain
  replicas                         = var.apps_replicas
  node_selector                    = var.apps_node_selector
  static_site_pass                 = var.static_site_pass
  static_site_user                 = var.static_site_user
  vaultwarden_options              = var.vaultwarden_options
  smtp_options                     = module.resources.smtp_options
  blog_domain                      = var.blog_domain
  github_config                    = var.github_config
  nats_streaming_http_producer_url = ""
  shared_db                        = var.shared_db
  minio = {
    server = var.minio.server
  }
  n8n_license_key                = var.n8n_license_key
  postiz                         = var.postiz
  crawl4ai                       = var.crawl4ai
  plausible                      = var.plausible
  visitor_badge                  = var.visitor_badge
  searxng_chart_version          = local.versions.charts.searxng
  n8n_chart_version              = local.versions.charts.n8n
  n8n_image_tag                  = local.versions.images.n8n
  postiz_image_tag               = local.versions.images.postiz
  plausible_version              = local.versions.images.plausible
  visitor_badge_image_tag        = local.versions.images.visitor_badge
  visitor_badge_backup_image_tag = local.versions.images.visitor_badge_backup
  crawl4ai_image_tag             = local.versions.images.crawl4ai
  blog_feature_post_image_tag    = local.versions.images.blog_feature_post
  blog_oauth_provider_image_tag  = local.versions.images.blog_oauth_provider
  vaultwarden_image_tag          = local.versions.images.vaultwarden
  vaultwarden_nginx_image_tag    = local.versions.images.vaultwarden_nginx
  redis_image_tag                = local.versions.images.redis
  busybox_image_tag              = local.versions.images.busybox
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
    "jellyseerr" = "jellyseerr.${var.domain}",
    "spotdl"     = "spotdl.${var.domain}",
  }
  sonarr_image_tag       = local.versions.images.sonarr
  radarr_image_tag       = local.versions.images.radarr
  prowlarr_image_tag     = local.versions.images.prowlarr
  spotdl_image_tag       = local.versions.images.spotdl
  jellyseerr_image_tag   = local.versions.images.jellyseerr
  flaresolverr_image_tag = local.versions.images.flaresolverr
}

module "mail" {
  source                 = "./mail"
  namespace              = var.namespaces.mail
  dovecot_config_dir     = var.dovecot_config_dir
  spampd_config_dir      = var.spampd_config_dir
  dns_server             = var.dns_server_ip
  db_config              = var.mail_db_config
  smtp_options           = module.resources.smtp_options
  domain                 = "mail.${var.domain}"
  postfix_admin_config   = var.postfix_admin_config
  dovecot-tag            = local.versions.images.dovecot
  spampd_tag             = local.versions.images.spampd
  spamassassin_tag       = local.versions.images.spamassassin
  postfixadmin_image_tag = local.versions.images.postfixadmin
  redis_image_tag        = local.versions.images.redis
}

module "code" {
  source    = "./code"
  namespace = var.namespaces.code
  forgejo_database = {
    type = var.shared_db.type
    host = var.shared_db.host
  }
  forgejo_ip      = var.code.server_ip
  public_host     = var.code.public_host
  smtp            = module.resources.smtp_options
  imap            = module.mail.private_imap_options
  email           = var.code.email_options
  forgejo_version = local.versions.charts.forgejo
}

module "monitoring" {
  source                      = "./monitoring"
  namespace                   = var.namespaces.monitoring
  domain                      = "monitoring.${var.domain}"
  external_ips                = var.monitroing_external_ips
  config_dir                  = var.monitoring_config_dir
  minio_endpoint              = var.minio.server
  prometheus_chart_version    = local.versions.charts.prometheus
  loki_chart_version          = local.versions.charts.loki
  tempo_chart_version         = local.versions.charts.tempo
  pyroscope_chart_version     = local.versions.charts.pyroscope
  grafana_chart_version       = local.versions.charts.grafana
  alloy_chart_version         = local.versions.charts.alloy
  graphite_exporter_image_tag = local.versions.images.graphite_exporter
}
