resource "kubernetes_secret_v1" "crawl4ai" {
  metadata {
    name      = "crawl4ai-secret"
    namespace = var.namespace
  }

  data = {
    for pair in [for line in split("\n", file(var.llm_credentail_file)) : trimspace(line)] :
    trimspace(split("=", pair)[0]) => trimspace(join("=", slice(split("=", pair), 1, length(split("=", pair)))))
    if length(pair) > 0 && !startswith(pair, "#")
  }

  type = "Opaque"
}

resource "kubernetes_deployment_v1" "crawl4ai" {
  metadata {
    name      = "crawl4ai"
    namespace = var.namespace
    labels = {
      app = "crawl4ai"
    }
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = {
        app = "crawl4ai"
      }
    }

    template {
      metadata {
        labels = {
          app = "crawl4ai"
        }
      }

      spec {
        container {
          name  = "crawl4ai"
          image = "unclecode/crawl4ai:${var.image_tag}"

          # ponytail: 0.9.0 is secure-by-default — the /mcp/sse endpoint (and
          # the HTTP API) require CRAWL4AI_API_TOKEN + Bearer auth, else it
          # binds loopback only. Ingress below still exposes it cluster-wide,
          # so add CRAWL4AI_API_TOKEN to crawl4ai-secret before relying on the
          # MCP endpoint. Deferred: wire the token when the agent is stood up.

          port {
            container_port = 11235
          }

          env_from {
            secret_ref {
              name = kubernetes_secret_v1.crawl4ai.metadata[0].name
            }
          }

          volume_mount {
            name       = "dshm"
            mount_path = "/dev/shm"
          }
        }
        volume {
          name = "dshm"

          empty_dir {
            medium     = "Memory"
            size_limit = "1Gi"
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "crawl4ai" {
  metadata {
    name      = "crawl4ai"
    namespace = var.namespace
  }

  spec {
    selector = {
      app = "crawl4ai"
    }

    port {
      port        = 80
      target_port = 11235
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_ingress_v1" "crawl4ai" {
  metadata {
    name      = "crawl4ai"
    namespace = var.namespace
    annotations = {
      "kubernetes.io/ingress.class" = "traefik"
    }
  }

  spec {
    rule {
      host = var.domain

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = kubernetes_service_v1.crawl4ai.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}
