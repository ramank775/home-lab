resource "kubernetes_namespace" "homelab_apps_namespace" {
  metadata {
    name = var.namespace
  }
}

# module "nats_streaming_http_producer" {
#   source          = "./nats-streaming-http-producer"
#   namespace       = var.namespace
#   replicas        = var.replicas.nats_streaming_http_producer
#   nats_url        = var.nats_url
#   nats_cluster_id = var.nats_cluster_id
#   node_selector   = var.node_selector
# }

# module "slack_notifier" {
#   source          = "./slack-notifier"
#   namespace       = var.namespace
#   replicas        = var.replicas.slack_notifier
#   nats_url        = var.nats_url
#   nats_cluster_id = var.nats_cluster_id
#   slack_endpoint  = var.slack_endpoint
#   node_selector   = var.node_selector
# }


module "visitor_badge" {
  source        = "./visitor-badge"
  namespace     = var.namespace
  replicas      = var.replicas.visitor_badge
  node_selector = var.node_selector
}

# module "static-site" {
#   source    = "./static-site"
#   namespace = var.namespace
#   username  = var.static_site_user
#   password  = var.static_site_pass
# }

module "vaultwarden" {
  source        = "./vaultwarden"
  namespace     = var.namespace
  domain        = "vw.${var.domain}"
  public_domain = lookup(var.vaultwarden_options, "public_domain", "vw.${var.domain}")
  sender_mail   = lookup(var.vaultwarden_options, "from_mail", "vaultwarden@${var.domain}")
  smtp_options  = var.smtp_options
}

module "blog" {
  source                           = "./blog"
  namespace                        = var.namespace
  domain                           = var.blog_domain
  github_config                    = var.github_config
  nats_streaming_http_producer_url = var.nats_streaming_http_producer_url
}

module "n8n" {
  source          = "./n8n"
  namespace       = var.namespace
  domain          = "n8n.${var.domain}"
  database        = var.shared_db
  minio           = var.minio
  n8n_license_key = var.n8n_license_key
}

module "postiz" {
  source            = "./postiz"
  namespace         = var.namespace
  domain            = var.postiz.domain
  database          = var.shared_db
  social_app_config = var.postiz.social_credentials_file
  smtp              = var.smtp_options
  email             = var.postiz.email
}

module "searxng" {
  source    = "./searxng"
  namespace = var.namespace
  domain    = "search.${var.domain}"
}

module "crawl4ai" {
  source                = "./crawl4ai"
  namespace             = var.namespace
  domain                = "scrapper.${var.domain}"
  llm_credentail_file   = var.crawl4ai.llm_credential_file
}

module "plausible" {
  source        = "./plausible"
  namespace     = var.namespace
  base_url      = var.plausible.url
  clickhouse    = var.plausible.clickhouse
  postgresql    = var.shared_db
  mailer        = var.plausible.mailer
  smtp_options  = var.smtp_options
}