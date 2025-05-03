output "private_imap_options" {
  value = {
    host = "${local.dovecotName}-service.${var.namespace}.svc.${var.cluster_domain}"
    port = 143
  }
}
