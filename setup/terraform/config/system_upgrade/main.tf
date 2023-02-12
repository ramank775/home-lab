resource "kubernetes_manifest" "server-upgrade" {
  manifest = {
    apiVersion = "upgrade.cattle.io/v1"
    kind       = "Plan"
    metadata = {
      name      = "server-plan"
      namespace = "system-upgrade"
    }
    spec = {
      concurrency = 1
      cordon      = true
      nodeSelector = {
        matchExpressions = [
          {
            key      = "node-role.kubernetes.io/master"
            operator = "In"
            values   = ["true"]
          }
        ]
      }
      serviceAccountName = "system-upgrade"
      upgrade = {
        image = "rancher/k3s-upgrade"
      }
      channel = "stable"
    }
  }
}

resource "kubernetes_manifest" "agent-upgrade" {
  manifest = {
    apiVersion = "upgrade.cattle.io/v1"
    kind       = "Plan"
    metadata = {
      name      = "agent-plan"
      namespace = "system-upgrade"
    }
    spec = {
      concurrency = 1
      cordon      = true
      nodeSelector = {
        matchExpressions = [
          {
            key      = "node-role.kubernetes.io/master"
            operator = "DoesNotExist"
          }
        ]
      }
      serviceAccountName = "system-upgrade"
      upgrade = {
        image = "rancher/k3s-upgrade"
      }
      channel = "stable"
      prepare = {
        args = [
          "prepare",
          "server-plan"
        ]
        image = "rancher/k3s-upgrade"
      }
    }
  }
}
