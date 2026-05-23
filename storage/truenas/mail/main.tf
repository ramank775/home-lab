resource "truenas_dataset" "mail" {
  pool        = "personal"
  name        = "mail"
  compression = "LZ4"
  atime       = "OFF"
  sync        = "STANDARD"
  record_size = "128K"
}
