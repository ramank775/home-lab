resource "truenas_dataset" "nextcloud" {
  pool        = "personal"
  name        = "nextcloud"
  compression = "LZ4"
  atime       = "OFF"
  sync        = "STANDARD"
  record_size = "128K"
}

resource "truenas_share_nfs" "nextcloud" {
  path         = "/mnt/personal/nextcloud"
  enabled      = true
  mapall_user  = "nextcloud"
  mapall_group = "nextcloud"
}
