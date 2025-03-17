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

# module "mail" {
#   source                       = "./mail"
#   namespace                    = var.namespace
#   domain                       = "mail.${var.domain}"
#   dovecot_config_dir           = var.dovecot_config_dir
#   tunnel_ssh_key               = var.tunnel_ssh_key
#   tunnel_proxy_host            = var.tunnel_proxy_host
#   tunnel_ssh_port              = var.tunnel_ssh_port
#   tunnel_ssh_user              = var.tunnel_ssh_user
#   spampd_config_dir            = var.spampd_config_dir
#   db_host                      = var.mail_db_host
#   db_port                      = var.mail_db_port
#   db_name                      = var.mail_db_name
#   db_user                      = var.mail_db_user
#   db_pass                      = var.mail_db_pass
#   db_type                      = var.mail_db_type
#   smtp_options                 = var.smtp_options
#   postfix_admin_setup_password = var.postfix_admin_setup_password
#   postfix_admin_encrypt        = var.postfix_admin_encrypt
#   mail_dns_server              = var.mail_dns_server
# }

module "blog" {
  source                           = "./blog"
  namespace                        = var.namespace
  domain                           = var.blog_domain
  github_config                    = var.github_config
  nats_streaming_http_producer_url = var.nats_streaming_http_producer_url
}
