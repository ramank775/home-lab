output "endpoint" {
  value = "http://${local.appname}.${var.namespace}.svc.${var.cluster_domain}:3000"
}
