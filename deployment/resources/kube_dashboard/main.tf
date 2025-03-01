locals {
  namespace = "kubernetes-dashboard"
}

resource "kubernetes_namespace" "kubernetes-dashboard-namespace" {
  metadata {
    name = local.namespace
  }
}

# resource "kubernetes_manifest" "kube-dashboard-ingress-middleware" {
#   manifest = {
#     apiVersion = "traefik.containo.us/v1alpha1"
#     kind       = "Middleware"
#     metadata = {
#       name      = "kube-strip-middleware-ingress"
#       namespace = local.namespace
#     }
#     spec = {
#       replacePathRegex = {
#         regex       = "/dashboard/(.*)"
#         replacement = "/$1"
#       }
#     }
#   }
# }

resource "kubernetes_service_account" "kube_dashboard" {
  metadata {
    name      = "kube-dash"
    namespace = local.namespace
  }
}

resource "kubernetes_cluster_role_binding" "kube_dashboard_readonly" {
  metadata {
    name = "kube-dashboard-readonly"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "view"
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.kube_dashboard.metadata[0].name
    namespace = kubernetes_service_account.kube_dashboard.metadata[0].namespace
  }
}
resource "helm_release" "kubernetes-dashboard" {
  depends_on = [
    kubernetes_namespace.kubernetes-dashboard-namespace,
  ]
  name            = "kubernetes-dashboard"
  repository      = "https://kubernetes.github.io/dashboard/"
  chart           = "kubernetes-dashboard"
  namespace       = local.namespace
  wait            = true
  upgrade_install = true
  version         = "7.10.4"

  set {
    name  = "app.model"
    value = "dashboard"
  }

  set {
    name  = "app.ingress.enabled"
    value = true
  }

  set {
    name  = "app.ingress.hosts[0]"
    value = var.domain
  }

  set {
    name = "app.ingress.useDefaultAnnotations"
    value = false
  }

  set {
    name  = "app.ingress.ingressClassName"
    value = "traefik"
  }
  set {
    name  = "app.ingress.annotations.kubernetes\\.io/ingress\\.class"
    value = "traefik"
  }

  set {
    name  = "app.ingress.annotations.traefik\\.ingress\\.kubernetes\\.io/service\\.serverstransport"
    value = "kube-system-traefix-insecure-server-transport@kubernetescrd"
  }

  set {
    name  = "app.ingress.annotations.traefik\\.ingress\\.kubernetes\\.io/service\\.serversscheme"
    value = "https"
  }

  set {
    name  = "kong.proxy.annotations.traefik\\.ingress\\.kubernetes\\.io/service\\.serverstransport"
    value = "kube-system-traefix-insecure-server-transport@kubernetescrd"
  }

  set {
    name  = "kong.proxy.annotations.traefik\\.ingress\\.kubernetes\\.io/service\\.serversscheme"
    value = "https"
  }

}
