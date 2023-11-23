locals {
  github_config = "github-config-secret"
  replicas      = 1
}

resource "kubernetes_secret" "github_config" {
  metadata {
    name      = local.github_config
    namespace = var.namespace
  }
  data = var.github_config
}
