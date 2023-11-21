locals {
  namespace = "democratic-csi"
}

resource "kubernetes_namespace" "democratic-namespace" {
  metadata {
    name = local.namespace
  }
}

resource "helm_release" "democratic" {
  depends_on = [
    kubernetes_namespace.democratic-namespace
  ]
  name       = "democratic-csi"
  repository = "https://democratic-csi.github.io/charts/"
  chart      = "democratic-csi"
  namespace  = local.namespace
  version    = "0.14.2"
  wait       = true
  set {
    name  = "csiDriver.name"
    value = "org.democratic-csi.iscsi"
  }

  set {
    name  = "driver.config.driver"
    value = "freenas-api-iscsi"
  }

  set {
    name  = "driver.config.httpConnection.protocol"
    value = "http"
  }

  set {
    name  = "driver.config.httpConnection.host"
    value = var.truenas_host
  }

  set {
    name  = "driver.config.httpConnection.port"
    value = var.truenas_port
  }

  set {
    name  = "driver.config.httpConnection.apiKey"
    value = var.truenas_apikey
  }

  set {
    name  = "driver.config.zfs.datasetParentName"
    value = "${var.truenas_pool}/k3s/vols"
  }

  set {
    name  = "driver.config.zfs.detachedSnapshotsDatasetParentName"
    value = "${var.truenas_pool}/k3s/snaps"
  }

  set {
    name  = "driver.config.iscsi.targetPortal"
    value = "${var.truenas_host}:3260"
  }

  set {
    name  = "driver.config.iscsi.namePrefix"
    value = "csi-"
  }

  set {
    name  = "driver.config.iscsi.nameSuffix"
    value = "-k3s"
  }

  set {
    name  = "driver.config.iscsi.extentInsecureTpc"
    value = true
  }

  set {
    name  = "driver.config.iscsi.extentXenCompat"
    value = false
  }

  set {
    name  = "driver.config.iscsi.extentDisablePhysicalBlocksize"
    value = true
  }

  set {
    name  = "driver.config.iscsi.extentBlocksize"
    value = 512
  }

  set {
    name  = "driver.config.iscsi.extentRpm"
    value = "5400"
  }

  set {
    name  = "driver.config.iscsi.extentAvailThreshold"
    value = 0
  }

  set {
    name  = "driver.config.iscsi.targetGroups[0].targetGroupPortalGroup"
    value = 1
  }

  set {
    name  = "driver.config.iscsi.targetGroups[0].targetGroupInitiatorGroup"
    value = 1
  }

  set {
    name  = "driver.config.iscsi.targetGroups[0].targetGroupAuthType"
    value = "None"
  }

  set {
    name  = "storageClasses[0].name"
    value = "truenas-iscsi-csi"
  }

  set {
    name  = "storageClasses[0].defaultClass"
    value = false
  }

  set {
    name  = "storageClasses[0].reclaimPolicy"
    value = "Delete"
  }

  set {
    name  = "storageClasses[0].volumeBindingMode"
    value = "Immediate"
  }

  set {
    name  = "storageClasses[0].allowVolumeExpansion"
    value = true
  }

  set {
    name  = "storageClasses[0].parameters.fsType"
    value = "ext4"
  }
}
