resource "random_password" "searxng_secret_key" {
  length  = 16
  special = true
}


resource "helm_release" "searxng" {
  name             = "searxng"
  namespace        = var.namespace
  chart            = "searxng"
  repository       = "https://charts.kubito.dev"
  version          = var.chart_version
  create_namespace = true

  set {
    name = "ingress.enabled"
    value = true
  }

  set {
    name = "ingress.className"
    value = "traefik"
  }

  set {
    name = "ingress.hosts[0].host"
    value = var.domain
  }

  set {
    name = "ingress.hosts[0].paths[0].path"
    value = "/"
  }

  set {
    name = "ingress.hosts[0].paths[0].pathType"
    value = "Prefix"
  }
  
}
