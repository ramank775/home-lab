# output "nats" {
#     value = {
#         "endpoint" = module.nats.endpoint
#         "cluster_id" = module.nats.cluster_id
#     }
# }

output "smtp_options" {
  value = {
    host = module.smtp-relay.smtp_host
    port = module.smtp-relay.smtp_port
  }
}

output "temporal_address" {
  description = "TEMPORAL_ADDRESS gRPC endpoint for in-cluster consumers"
  value       = module.temporal.address
}