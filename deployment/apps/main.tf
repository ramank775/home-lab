resource "kubernetes_namespace" "homelab_apps_namespace" {
  metadata {
    name = var.namespace
  }
}

module "visitor_badge" {
  source          = "./visitor-badge"
  namespace       = var.namespace
  replicas        = var.replicas.visitor_badge
  node_selector   = var.node_selector
  md5_key         = var.visitor_badge.md5_key
  admin_api_key   = var.visitor_badge.admin_api_key
  tag             = var.visitor_badge_image_tag
  backup_tag      = var.visitor_badge_backup_image_tag
  redis_image_tag = var.redis_image_tag
}

module "vaultwarden" {
  source          = "./vaultwarden"
  namespace       = var.namespace
  domain          = "vw.${var.domain}"
  public_domain   = lookup(var.vaultwarden_options, "public_domain", "vw.${var.domain}")
  sender_mail     = lookup(var.vaultwarden_options, "from_mail", "vaultwarden@${var.domain}")
  smtp_options    = var.smtp_options
  image_tag       = var.vaultwarden_image_tag
  nginx_image_tag = var.vaultwarden_nginx_image_tag
}

module "blog" {
  source                           = "./blog"
  namespace                        = var.namespace
  domain                           = var.blog_domain
  github_config                    = var.github_config
  nats_streaming_http_producer_url = var.nats_streaming_http_producer_url
  feature_post_image_tag           = var.blog_feature_post_image_tag
  oauth_provider_image_tag         = var.blog_oauth_provider_image_tag
}

module "n8n" {
  source          = "./n8n"
  namespace       = var.namespace
  domain          = "n8n.${var.domain}"
  database        = var.shared_db
  minio           = var.minio
  n8n_license_key = var.n8n_license_key
  helm_version    = var.n8n_chart_version
  image_tag       = var.n8n_image_tag
}

module "postiz" {
  source            = "./postiz"
  namespace         = var.namespace
  domain            = var.postiz.domain
  database          = var.shared_db
  social_app_config = var.postiz.social_credentials_file
  smtp              = var.smtp_options
  email             = var.postiz.email
  image_tag         = var.postiz_image_tag
  redis_image_tag   = var.redis_image_tag
  temporal_address  = var.temporal_address
}

module "searxng" {
  source        = "./searxng"
  namespace     = var.namespace
  domain        = "search.${var.domain}"
  chart_version = var.searxng_chart_version
}

module "crawl4ai" {
  source              = "./crawl4ai"
  namespace           = var.namespace
  domain              = "scrapper.${var.domain}"
  llm_credentail_file = var.crawl4ai.llm_credential_file
  image_tag           = var.crawl4ai_image_tag
}

module "listmonk" {
  source    = "./listmonk"
  namespace = var.namespace
  domain    = "newsletter.${var.domain}"
  database  = var.shared_db
  smtp      = var.smtp_options
  email     = var.listmonk.email
  admin     = var.listmonk.admin
  image_tag = var.listmonk_image_tag
}

module "joplin" {
  source    = "./joplin"
  namespace = var.namespace
  domain    = "notes.${var.domain}"
  database  = var.shared_db
  smtp      = var.smtp_options
  email     = var.joplin.email
  image_tag = var.joplin_image_tag
}

module "cloudbeaver" {
  source    = "./cloudbeaver"
  namespace = var.namespace
  domain    = "db.${var.domain}"
  image_tag = var.cloudbeaver_image_tag
}

module "plausible" {
  source                             = "./plausible"
  namespace                          = var.namespace
  base_url                           = var.plausible.url
  clickhouse                         = var.plausible.clickhouse
  postgresql                         = var.shared_db
  mailer                             = var.plausible.mailer
  smtp_options                       = var.smtp_options
  google_oauth_credentials_file_path = var.plausible.google_oauth_credentials_file_path
  plausible_version                  = var.plausible_version
  busybox_image_tag                  = var.busybox_image_tag
}

# --- Proxmox-backed apps (LXCs and VMs) -----------------------------------

module "nextcloud" {
  source    = "./nextcloud"
  node_name = var.node_name
  ips       = var.ips
}

module "home-assistant" {
  source    = "./home-assistant"
  node_name = var.node_name
}

module "wordpress" {
  source    = "./wordpress"
  node_name = var.node_name
}