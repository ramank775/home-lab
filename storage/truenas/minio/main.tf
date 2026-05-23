resource "truenas_dataset" "minio" {
  pool        = "lab-storage"
  name        = "minio"
  compression = "LZ4"
  atime       = "OFF"
  sync        = "STANDARD"
  record_size = "128K"
}

resource "truenas_dataset" "minio_data" {
  pool           = "lab-storage"
  parent_dataset = "minio"
  name           = "data"
  compression    = "LZ4"
  atime          = "OFF"
  sync           = "STANDARD"
  record_size    = "128K"
}

resource "truenas_dataset" "minio_export" {
  pool           = "lab-storage"
  parent_dataset = "minio"
  name           = "export"
  compression    = "LZ4"
  atime          = "OFF"
  sync           = "STANDARD"
  record_size    = "128K"
}
