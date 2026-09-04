locals {
  namespace = "headlamp"
}

resource "kubernetes_namespace_v1" "headlamp" {
  metadata {
    name = local.namespace
  }
}

resource "helm_release" "headlamp" {
  depends_on = [
    kubernetes_namespace_v1.headlamp,
  ]
  name            = "headlamp"
  repository      = "https://kubernetes-sigs.github.io/headlamp/"
  chart           = "headlamp"
  namespace       = local.namespace
  wait            = true
  upgrade_install = true
  version         = var.chart_version

  set {
    name  = "clusterRoleBinding.create"
    value = true
  }

  set {
    name  = "clusterRoleBinding.clusterRoleName"
    value = "view"
  }

  set {
    name  = "ingress.enabled"
    value = true
  }

  set {
    name  = "ingress.ingressClassName"
    value = "traefik"
  }

  set {
    name  = "ingress.hosts[0].host"
    value = var.domain
  }

  set {
    name  = "ingress.hosts[0].paths[0].path"
    value = "/"
  }

  set {
    name  = "ingress.hosts[0].paths[0].type"
    value = "Prefix"
  }
}
