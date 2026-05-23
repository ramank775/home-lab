// Parent datasets for k3s storage. Children are managed by the CSI driver
// inside k3s and are NOT tracked here (the CSI is the source of truth for
// per-PVC datasets and iSCSI targets).

resource "truenas_dataset" "k3s" {
  pool        = "lab-storage"
  name        = "k3s"
  compression = "LZ4"
  atime       = "OFF"
  sync        = "STANDARD"
  record_size = "128K"
}

resource "truenas_dataset" "k3s_nfs_vol" {
  pool           = "lab-storage"
  parent_dataset = "k3s"
  name           = "nfs-vol"
  compression    = "LZ4"
  atime          = "OFF"
  sync           = "STANDARD"
  record_size    = "128K"
}

resource "truenas_dataset" "k3s_vols" {
  pool           = "lab-storage"
  parent_dataset = "k3s"
  name           = "vols"
  compression    = "LZ4"
  atime          = "OFF"
  sync           = "STANDARD"
  record_size    = "128K"
}

resource "truenas_dataset" "k3s_snaps" {
  pool           = "lab-storage"
  parent_dataset = "k3s"
  name           = "snaps"
  compression    = "LZ4"
  atime          = "OFF"
  sync           = "STANDARD"
  record_size    = "128K"
}
