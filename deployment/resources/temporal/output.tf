output "address" {
  description = "gRPC address consumers should set as TEMPORAL_ADDRESS"
  value       = "${kubernetes_service_v1.temporal_server.metadata[0].name}.${var.namespace}.svc.cluster.local:7233"
}
