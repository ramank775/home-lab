output "nats_streaming_http_producer" {
  value = {
    endpoint = module.nats_streaming_http_producer.endpoint
  }
}

output "visitor_badge" {
  value = {
    endpoint = module.visitor_badge.endpoint
  }
}