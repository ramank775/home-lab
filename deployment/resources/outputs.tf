output "nats" {
    value = {
        "endpoint" = module.nats.endpoint
        "cluster_id" = module.nats.cluster_id
    }
}
