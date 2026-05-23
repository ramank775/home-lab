// WordPress serverless: dataset tuned for many small files (16K recordsize,
// sync disabled for speed) and an NFS share exposed to PVE + the cluster VIP.

resource "truenas_dataset" "wp_serverless" {
  pool        = "lab-storage"
  name        = "wp-serverless"
  compression = "LZ4"
  atime       = "OFF"
  sync        = "STANDARD"
  record_size = "128K"
}

resource "truenas_dataset" "storage" {
  pool           = "lab-storage"
  parent_dataset = "wp-serverless"
  name           = "storage"
  compression    = "LZ4"
  atime          = "OFF"
  sync           = "DISABLED"
  record_size    = "16K"
}

resource "truenas_share_nfs" "storage" {
  path          = "/mnt/lab-storage/wp-serverless/storage"
  comment       = "Wordpress Serverless Shared Storage"
  enabled       = true
  hosts         = var.share_hosts
  maproot_user  = "wp"
  maproot_group = "wp"
}
