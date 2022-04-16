locals {
  image    = "${var.image}:${var.tag}"
  appname  = "nats-streaming-http-producer"
  replicas = var.replicas
}

resource "kubernetes_deployment" "nats_streaming_http_producer_deployement" {
  metadata {
    name      = local.appname
    namespace = var.namespace
    labels = {
      "app" = local.appname
    }
  }

  spec {
    replicas = local.replicas
    selector {
      match_labels = {
        "app" = local.appname
      }
    }
    template {
      metadata {
        labels = {
          "app" = local.appname
        }
      }

      spec {
        container {
          name = local.appname
          resources {
            limits = {
              "memory" = var.memorylimit
            }
          }
          image             = local.image
          image_pull_policy = "IfNotPresent"
          env {
            name  = "PORT"
            value = "3000"
          }
          env {
            name  = "NATS_CLUSTER_ID"
            value = var.nats_cluster_id
          }
          env {
            name  = "NATS_CLIENT_ID"
            value = var.client_id
          }
          env {
            name  = "NATS_URL"
            value = var.nats_url
          }
          port {
            container_port = 3000
            protocol       = "TCP"
          }
          readiness_probe {
            http_get {
              path = "/health"
              port = 3000
            }
            timeout_seconds = 30
          }
          liveness_probe {
            http_get {
              path = "/health"
              port = 3000
            }
            timeout_seconds = 30
          }
        }
        node_selector = var.node_selector
      }
    }

  }
}

resource "kubernetes_service" "nats_streaming_http_producer_service" {
  metadata {
    name      = local.appname
    namespace = var.namespace
    labels = {
      "app" = local.appname
    }
  }

  spec {
    type = "ClusterIP"
    selector = {
      "app" = local.appname
    }
    port {
      name     = "endpoint"
      port     = 3000
      protocol = "TCP"
    }
  }
}
