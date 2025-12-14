resource "kubernetes_namespace" "media" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_persistent_volume" "media-directory" {
  metadata {
    name = "media-directory"
  }
  spec {
    storage_class_name = "standard"
    capacity = {
      "storage" = var.media_storage.capacity
    }
    access_modes = ["ReadWriteMany"]
    persistent_volume_source {
      nfs {
        server    = var.media_storage.host
        path      = var.media_storage.path
        read_only = false
      }
    }
    mount_options = [
      "hard",
      "nfsvers=4.1"
    ]
  }
}

resource "kubernetes_persistent_volume_claim" "media-data" {
  metadata {
    name      = "media-data"
    namespace = var.namespace
  }
  wait_until_bound = true
  spec {
    storage_class_name = "standard"
    access_modes       = ["ReadWriteMany"]
    volume_name        = "media-directory"
    resources {
      requests = {
        "storage" = var.media_storage.capacity
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "sonarr-config" {
  metadata {
    name      = "sonarr-config"
    namespace = var.namespace
  }
  wait_until_bound = true
  spec {
    resources {
      requests = {
        "storage" = "2Gi"
      }
    }
    storage_class_name = "truenas-iscsi-csi"
    access_modes       = ["ReadWriteOnce"]
  }
}

resource "kubernetes_deployment" "sonarr" {
  metadata {
    name      = "sonarr"
    namespace = var.namespace
    labels = {
      "media.app" = "sonarr"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        "media.app" = "sonarr"
      }
    }
    template {
      metadata {
        labels = {
          "media.app" = "sonarr"
        }
      }
      spec {
        container {
          image = "lscr.io/linuxserver/sonarr:latest"
          name  = "sonarr"
          port {
            container_port = 8989
          }
          env {
            name  = "PUID"
            value = 8000
          }
          env {
            name  = "PGID"
            value = 8000
          }
          env {
            name  = "TZ"
            value = "Asia/Kolkata"
          }
          volume_mount {
            name       = "config"
            mount_path = "/config"
          }
          volume_mount {
            name       = "media-data"
            mount_path = "/data"
          }
        }
        volume {
          name = "config"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.sonarr-config.metadata.0.name
          }
        }
        volume {
          name = "media-data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.media-data.metadata.0.name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "sonarr" {
  metadata {
    name      = "sonarr"
    namespace = var.namespace
  }
  spec {
    type = "ClusterIP"
    selector = {
      "media.app" = "sonarr"
    }
    port {
      port = 8989
    }
  }
  depends_on = [
    kubernetes_deployment.sonarr
  ]
}

resource "kubernetes_persistent_volume_claim" "radarr-config" {
  metadata {
    name      = "radarr-config"
    namespace = var.namespace
  }
  wait_until_bound = true
  spec {
    resources {
      requests = {
        "storage" = "2Gi"
      }
    }
    storage_class_name = "truenas-iscsi-csi"
    access_modes       = ["ReadWriteOnce"]
  }
}

resource "kubernetes_deployment" "radarr" {
  metadata {
    name      = "radarr"
    namespace = var.namespace
    labels = {
      "media.app" = "radarr"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        "media.app" = "radarr"
      }
    }
    template {
      metadata {
        labels = {
          "media.app" = "radarr"
        }
      }
      spec {
        container {
          image = "lscr.io/linuxserver/radarr:latest"
          name  = "radarr"
          port {
            container_port = 7878
          }
          env {
            name  = "PUID"
            value = 8000
          }
          env {
            name  = "PGID"
            value = 8000
          }
          env {
            name  = "TZ"
            value = "Asia/Kolkata"
          }
          volume_mount {
            name       = "config"
            mount_path = "/config"
          }
          volume_mount {
            name       = "media-data"
            mount_path = "/data"
          }
        }
        volume {
          name = "config"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.radarr-config.metadata.0.name
          }
        }
        volume {
          name = "media-data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.media-data.metadata.0.name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "radarr" {
  metadata {
    name      = "radarr"
    namespace = var.namespace
  }
  spec {
    type = "ClusterIP"
    selector = {
      "media.app" = "radarr"
    }
    port {
      port = 7878
    }
  }
  depends_on = [
    kubernetes_deployment.radarr
  ]
}

resource "kubernetes_persistent_volume_claim" "prowlarr-config" {
  metadata {
    name      = "prowlarr-config"
    namespace = var.namespace
  }
  wait_until_bound = true
  spec {
    resources {
      requests = {
        "storage" = "1Gi"
      }
    }
    storage_class_name = "truenas-iscsi-csi"
    access_modes       = ["ReadWriteOnce"]
  }
}

resource "kubernetes_deployment" "prowlarr" {
  metadata {
    name      = "prowlarr"
    namespace = var.namespace
    labels = {
      "media.app" = "prowlarr"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        "media.app" = "prowlarr"
      }
    }

    template {
      metadata {
        labels = {
          "media.app" = "prowlarr"
        }
      }

      spec {
        container {
          image = "lscr.io/linuxserver/prowlarr:latest"
          name  = "prowlarr"
          env {
            name  = "PUID"
            value = 8000
          }
          env {
            name  = "PGID"
            value = 8000
          }
          env {
            name  = "TZ"
            value = "Asia/Kolkata"
          }
          port {
            container_port = 9696
          }
          volume_mount {
            name       = "config"
            mount_path = "/config"
          }
        }
        volume {
          name = "config"
          persistent_volume_claim {
            claim_name = "prowlarr-config"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "prowlarr" {
  metadata {
    name      = "prowlarr"
    namespace = var.namespace
  }
  spec {
    type = "ClusterIP"
    selector = {
      "media.app" = "prowlarr"
    }
    port {
      port        = 9696
      target_port = 9696
    }
  }
  depends_on = [
    kubernetes_deployment.prowlarr
  ]
}

resource "kubernetes_deployment" "spotdl" {
  metadata {
    name      = "spotdl"
    namespace = var.namespace
    labels = {
      "media.app" = "spotdl"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        "media.app" = "spotdl"
      }
    }
    template {
      metadata {
        labels = {
          "media.app" = "spotdl"
        }
      }
      spec {
        container {
          name  = "spotdl"
          image = "spotdl/spotify-downloader:latest"
          args    = [
            "web", 
            "--host", "0.0.0.0",
            "--port", "8080", 
            "--web-use-output-dir",
            "--output", "/music/{album}/{title}.{output-ext}",
            "--log-level", "DEBUG"
          ]
          env {
            name  = "PUID"
            value = 8000
          }
          env {
            name  = "PGID"
            value = 8000
          }
          env {
            name  = "TZ"
            value = "Asia/Kolkata"
          }
          volume_mount {
            name       = "media-data"
            mount_path = "/music"
            sub_path = "music"
          }
        }
        volume {
          name = "media-data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.media-data.metadata.0.name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "spotdl" {
  metadata {
    name      = "spotdl"
    namespace = var.namespace
  }
  spec {
    type = "ClusterIP"
    selector = {
      "media.app" = "spotdl"
    }
    port {
      port = 8080
    }
  }
  depends_on = [
    kubernetes_deployment.spotdl
  ]
}

resource "kubernetes_persistent_volume_claim" "jellyseerr-config" {
  metadata {
    name      = "jellyseerr-config"
    namespace = var.namespace
  }
  wait_until_bound = true
  spec {
    resources {
      requests = {
        "storage" = "1Gi"
      }
    }
    storage_class_name = "truenas-iscsi-csi"
    access_modes       = ["ReadWriteOnce"]
  }
}

resource "kubernetes_deployment" "jellyseerr" {
  metadata {
    name      = "jellyseerr"
    namespace = var.namespace
    labels = {
      "media.app" = "jellyseerr"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        "media.app" = "jellyseerr"
      }
    }

    template {
      metadata {
        labels = {
          "media.app" = "jellyseerr"
        }
      }

      spec {
        container {
          image = "fallenbagel/jellyseerr:latest"
          name  = "jellyseerr"
          env {
            name  = "TZ"
            value = "Asia/Kolkata"
          }
          env {
            name  = "LOG_LEVEL"
            value = "debug"
          }
          # env {
          #   name  = "HOST"
          #   value = "0.0.0.0"
          # }
          env {
            name  = "PORT"
            value = "5055"
          }
          port {
            container_port = 5055
            name           = "http"
          }
          volume_mount {
            name       = "config"
            mount_path = "/app/config"
          }
        }
        volume {
          name = "config"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.jellyseerr-config.metadata.0.name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "jellyseerr" {
  metadata {
    name      = "jellyseerr"
    namespace = var.namespace
  }
  spec {
    type = "ClusterIP"
    selector = {
      "media.app" = "jellyseerr"
    }
    port {
      name        = "http"
      port        = 5055
      target_port = "http"
    }
  }
  depends_on = [
    kubernetes_deployment.jellyseerr
  ]
}

resource "kubernetes_deployment" "flaresovlerr" {
  metadata {
    name      = "flaresolverr"
    namespace = var.namespace
    labels = {
      "media.app" = "flaresolverr"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        "media.app" = "flaresolverr"
      }
    }
    template {
      metadata {
        labels = {
          "media.app" = "flaresolverr"
        }
      }
      spec {
        container {
          name  = "flaresolverr"
          image = "ghcr.io/flaresolverr/flaresolverr:latest"
          env {
            name  = "TZ"
            value = "Asia/Kolkata"
          }

          env {
            name  = "LOG_HTML"
            value = "false"
          }

          env {
            name  = "CAPTCHA_SOLVER"
            value = "hcaptcha-solver"
          }
          port {
            container_port = 8191
            name           = "http"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "flaresovlerr" {
  metadata {
    name      = "flaresolverr"
    namespace = var.namespace
  }
  spec {
    type = "ClusterIP"
    selector = {
      "media.app" = "flaresolverr"
    }
    port {
      port        = 80
      target_port = 8191
    }
  }
  depends_on = [
    kubernetes_deployment.prowlarr
  ]
}

resource "kubernetes_ingress_v1" "media-management" {
  metadata {
    name      = "media-management-ingress"
    namespace = var.namespace
    annotations = {
      "kubernetes.io/ingress.class" = "traefik"

    }
  }
  spec {
    rule {
      host = var.domains.media-mgmt
      http {
        path {
          path = "/sonarr"
          backend {
            service {
              name = kubernetes_service.sonarr.metadata.0.name
              port {
                number = 8989
              }
            }
          }
        }
        path {
          path = "/radarr"
          backend {
            service {
              name = kubernetes_service.radarr.metadata.0.name
              port {
                number = 7878
              }
            }
          }
        }
      }
    }
    rule {
      host = var.domains.spotdl
      http {
        path {
          path = "/"
          backend {
            service {
              name = kubernetes_service.spotdl.metadata.0.name
              port {
                number = 8080
              }
            }
          }
        }
      }
    }
    rule {
      host = var.domains.jellyseerr
      http {
        path {
          path = "/"
          backend {
            service {
              name = kubernetes_service.jellyseerr.metadata.0.name
              port {
                number = 5055
              }
            }
          }
        }
      }
    }
    rule {
      host = var.domains.prowlarr
      http {
        path {
          path = "/"
          backend {
            service {
              name = kubernetes_service.prowlarr.metadata.0.name
              port {
                number = 9696
              }
            }
          }
        }
      }
    }
  }
}
