locals {
  storageClass = "truenas-iscsi-csi"
}

resource "kubernetes_namespace" "monitoring-namespace" {
  metadata {
    name = var.namespace
  }
}

# Prometheus Installation
resource "helm_release" "prometheus" {
  name             = "prometheus"
  namespace        = var.namespace
  create_namespace = false

  chart      = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  version    = "25.27.0"

  values = [
    <<EOF
    configmapReload:
      prometheus:
        enabled: false
    prometheus-pushgateway:
      enabled: false
    prometheus-node-exporter:
      enabled: true
    kube-state-metrics:
      enabled: true
    alertmanager:
      enabled: true
      persistence:
        size: 1Gi
        storageClass: "${var.storageClassName}"
    server:
      extraArgs:
        web.enable-remote-write-receiver: null
        log.level: debug
      persistentVolume:
        enabled: true
        storageClass: "${var.storageClassName}"
        size: 10Gi
      podLabels:
        stack: monitoring
    EOF
  ]
}

# Loki Installation
resource "helm_release" "loki" {
  name       = "loki"
  namespace  = var.namespace
  chart      = "loki"
  repository = "https://grafana.github.io/helm-charts"
  version    = "6.16.0"

  values = [
    <<EOF
    deploymentMode: SingleBinary
    loki:
      podLabels:
        stack: monitoring
      auth_enabled: false
      persistence:
        enabled: true
        storageClassName: "${var.storageClassName}"
        size: 10Gi
      storage:
        type: filesystem
      commonConfig:
        replication_factor: 1
      schemaConfig:
        configs:
        - from: "2024-01-01"
          store: tsdb
          index:
            prefix: loki_index_
            period: 24h
          object_store: filesystem # we're storing on filesystem so there's no real persistence here.
          schema: v13
      memcached:
        chunk_cache:
          enabled: false
        results_cache:
          enabled: false
    test:
      enabled: false
    chunksCache:
      enabled: false
    resultsCache:
      enabled: false
    lokiCanary:
      enabled: false
    gateway:
      enabled: false
    singleBinary:
        replicas: 1
    read:
      replicas: 0
    backend:
      replicas: 0
    write:
      replicas: 0
    ingester:
      replicas: 0
    querier:
      replicas: 0
    queryFrontend:
      replicas: 0
    queryScheduler:
      replicas: 0
    distributor:
      replicas: 0
    compactor:
      replicas: 0
    indexGateway:
      replicas: 0
    bloomCompactor:
      replicas: 0
    bloomGateway:
      replicas: 0
    EOF
  ]
}

# Tempo Installation for distributed tracing
resource "helm_release" "tempo" {
  name       = "tempo"
  namespace  = var.namespace
  chart      = "tempo"
  repository = "https://grafana.github.io/helm-charts"
  version    = "1.10.3"

  values = [
    <<EOF
    server:
      http_listen_port: 3200
    podLabels:
      stack: monitoring
    storage:
      trace:
        backend: local
    persistence:
      enabled: true
      storageClassName: "${var.storageClassName}"
      size: 10Gi
    EOF
  ]
}

# Pyroscope Installation for continuous profiling
resource "helm_release" "pyroscope" {
  name       = "pyroscope"
  namespace  = var.namespace
  chart      = "pyroscope"
  repository = "https://grafana.github.io/helm-charts"
  version    = "1.7.1"

  values = [
    <<EOF
    pyroscope:
      extraLabels:
        stack: monitoring
      persistence:
        enabled: true
        storageClassName: "${var.storageClassName}"
        size: 10Gi
    alloy:
      enabled: false
    EOF
  ]
}

# Grafana Datasource ConfigMap (Integrate Prometheus, Loki, Tempo, Pyroscope)
resource "kubernetes_config_map" "grafana_datasource" {
  metadata {
    name      = "grafana-datasources"
    namespace = var.namespace
  }

  data = {
    "datasource.yaml" = <<EOT
apiVersion: 1
datasources:
  - name: Prometheus
    type: prometheus
    url: http://prometheus-server.monitoring.svc.cluster.local
    access: proxy
    isDefault: true
  - name: Loki
    type: loki
    url: http://loki.monitoring.svc.cluster.local:3100
    access: proxy
    isDefault: false
  - name: Tempo
    type: tempo
    url: http://tempo.monitoring.svc.cluster.local:3200
    access: proxy
    isDefault: false
  - name: Pyroscope
    type: pyroscope
    url: http://pyroscope.monitoring.svc.cluster.local:4040
    access: proxy
    isDefault: false
  - name: Alertmanager
    type: alertmanager
    url: http://prometheus-alertmanager.monitoring.svc.cluster.local
    access: proxy
    jsonData:
      implementation: prometheus
      handleGrafanaManagedAlerts: true
EOT
  }

  depends_on = [
    helm_release.prometheus,
    helm_release.loki,
    helm_release.tempo,
    helm_release.pyroscope
  ]
}


# Grafana Installation for dashboards
resource "helm_release" "grafana" {
  name       = "grafana"
  namespace  = var.namespace
  chart      = "grafana"
  repository = "https://grafana.github.io/helm-charts"
  version    = "8.5.2"

  values = [
    <<EOF
    persistence:
      enabled: true
      storageClassName: "${var.storageClassName}"
      size: 10Gi

    extraVolumes:
      - name: datasource-config
        configMap:
          name: grafana-datasources

    extraVolumeMounts:
      - name: datasource-config
        mountPath: /etc/grafana/provisioning/datasources/datasource.yaml
        subPath: datasource.yaml
    ingress:
      enabled: true
      hosts:
      - ${var.domain}
      
    EOF
  ]

  depends_on = [
    kubernetes_config_map.grafana_datasource
  ]
}


resource "kubernetes_config_map" "alloy-config" {
  metadata {
    name      = "alloy-config"
    namespace = var.namespace
  }

  data = {
    "config.alloy"          = file("${var.config_dir}/grafana-allow-config.alloy")
    "graphite_mapping.yaml" = file("${var.config_dir}/graphite_mapping.yaml")
  }
}

resource "helm_release" "grafana-alloy" {
  name       = "grafana-alloy"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "alloy"
  namespace  = var.namespace

  set {
    name  = "alloy.stabilityLevel"
    value = "experimental"
  }

  set {
    name  = "alloy.enableReporting"
    value = "false"
  }

  set {
    name  = "alloy.listenPort"
    value = "80"
  }

  set {
    name  = "ingress.faroPort"
    value = "80"
  }

  set {
    name  = "alloy.extraPorts.1.name"
    value = "prometheus"
  }
  set {
    name  = "alloy.extraPorts.1.port"
    value = "9091"
  }
  set {
    name  = "alloy.extraPorts.1.targetPort"
    value = "9091"
  }

  set {
    name  = "alloy.extraPorts.2.name"
    value = "loki"
  }
  set {
    name  = "alloy.extraPorts.2.port"
    value = "3100"
  }
  set {
    name  = "alloy.extraPorts.2.targetPort"
    value = "3100"
  }

  set {
    name  = "alloy.extraPorts.3.name"
    value = "statsd-tcp"
  }
  set {
    name  = "alloy.extraPorts.3.port"
    value = "2003"
  }
  set {
    name  = "alloy.extraPorts.3.targetPort"
    value = "2003"
  }
  set {
    name  = "alloy.extraPorts.3.protocol"
    value = "TCP"
  }
  set {
    name  = "alloy.extraPorts.4.name"
    value = "statsd-udp"
  }
  set {
    name  = "alloy.extraPorts.4.port"
    value = "2003"
  }
  set {
    name  = "alloy.extraPorts.4.targetPort"
    value = "2003"
  }
  set {
    name  = "alloy.extraPorts.4.protocol"
    value = "UDP"
  }
  set {
    name  = "alloy.extraPorts.5.name"
    value = "tempo-otlp-grpc"
  }
  set {
    name  = "alloy.extraPorts.5.port"
    value = "4317"
  }
  set {
    name  = "alloy.extraPorts.5.targetPort"
    value = "4317"
  }
  set {
    name  = "alloy.extraPorts.6.name"
    value = "tempo-otlp-http"
  }
  set {
    name  = "alloy.extraPorts.6.port"
    value = "4318"
  }
  set {
    name  = "alloy.extraPorts.6.targetPort"
    value = "4318"
  }

  set {
    name  = "controller.type"
    value = "deployment"
  }

  set {
    name  = "alloy.mounts.varlog"
    value = "true"
  }

  set {
    name  = "alloy.configMap.create"
    value = "false"
  }

  set {
    name  = "alloy.configMap.name"
    value = kubernetes_config_map.alloy-config.metadata.0.name
  }

  set {
    name  = "ingress.enabled"
    value = "true"
  }

  set_list {
    name = "ingress.hosts"
    value = [
      "alloy.${var.domain}"
    ]
  }

  depends_on = [
    kubernetes_config_map.alloy-config
  ]
}


# Graphite Exporter
resource "kubernetes_deployment" "graphite_exporter" {
  metadata {
    name      = "graphite-exporter"
    namespace = var.namespace
    labels = {
      app   = "graphite-exporter"
      stack = "monitoring"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "graphite-exporter"
      }
    }

    template {
      metadata {
        labels = {
          app                    = "graphite-exporter"
          stack                  = "monitoring"
          "observability/scrape" = "true"
        }
        annotations = {
          "observability/scrape" = "true"
          "prometheus.io/scrape" = true
          "prometheus.io/scheme" = "http"
          "prometheus.io/path"   = "/metrics"
          "prometheus.io/port"   = 9108
        }
      }

      spec {
        container {
          name  = "graphite-exporter"
          image = "quay.io/prometheus/graphite-exporter:latest"
          args = [
            "--graphite.mapping-config=/tmp/graphite_mapping.yaml",
            "--log.level=debug"
          ]

          port {
            container_port = 9109
          }

          volume_mount {
            mount_path = "/tmp"
            name       = "mapping"
          }
        }

        volume {
          name = "mapping"
          config_map {
            name = kubernetes_config_map.alloy-config.metadata.0.name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "graphite_exporter" {
  metadata {
    name      = "graphite-exporter"
    namespace = var.namespace
    labels = {
      app   = "graphite-exporter"
      stack = "monitoring"
    }
  }

  spec {
    selector = {
      app = "graphite-exporter"
    }

    port {
      port        = 9109
      target_port = 9109
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_service" "graphite_exporter_lb" {
  metadata {
    name      = "graphite-exporter-lb"
    namespace = var.namespace
    labels = {
      app   = "graphite-exporter"
      stack = "monitoring"
    }
  }

  spec {
    selector = {
      app = "graphite-exporter"
    }

    port {
      port        = 9109
      target_port = 9109
    }

    type             = "LoadBalancer"
    load_balancer_ip = var.external_ips.graphite
  }
}

resource "kubernetes_service" "monitoring-lb" {
  metadata {
    name      = "monitoring-lb"
    namespace = var.namespace
    annotations = {
      "metallb.universe.tf/ip-allocated-from-pool" = "homelab-ip"
    }
  }
  spec {
    type             = "LoadBalancer"
    load_balancer_ip = var.external_ips.default
    port {
      name        = "prometheus-push"
      port        = 9091
      target_port = 9091
    }
    port {
      name        = "loki"
      port        = 3100
      target_port = 3100
    }
    port {
      name        = "pyroscope"
      port        = 4040
      target_port = 4040
    }
    port {
      name        = "tempo-otlp-grpc"
      port        = 4317
      target_port = 4317
    }
    port {
      name        = "tempo-otlp-http"
      port        = 4318
      target_port = 4318
    }
    port {
      name        = "graphite"
      port        = 2003
      target_port = 2003
    }
    port {
      name         = "graphite-udp"
      port         = 2003
      target_port  = 2003
      app_protocol = "UDP"
      protocol     = "UDP"
    }
    selector = {
      "app.kubernetes.io/name" = "alloy"
    }
  }
}
