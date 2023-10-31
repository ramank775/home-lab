output "smtp_host" {
  value = "smtp-relay.${var.namespace}.svc.${var.cluster_domain}"
}

output "smtp_port" {
  value = 25
}
