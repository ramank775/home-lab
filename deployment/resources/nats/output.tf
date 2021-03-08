output "endpoint" {
  value = "nats://nats.${var.namespace}.svc.${var.cluster_domain}:4222"
}

output "monitoring_endpoint" {
    value = "nats.${var.namespace}.svc.${var.cluster_domain}:8222"
}

output "cluster_id" {
  value = var.clusterid
}
