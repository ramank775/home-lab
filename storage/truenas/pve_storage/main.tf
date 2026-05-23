// Datasets that back Proxmox VE storage (NFS-mounted by PVE).

resource "truenas_dataset" "vm" {
  pool        = "lab-storage"
  name        = "vm"
  compression = "LZ4"
  atime       = "OFF"
  sync        = "STANDARD"
  record_size = "128K"
}

resource "truenas_dataset" "vm_boot_disk" {
  pool           = "lab-storage"
  parent_dataset = "vm"
  name           = "boot-disk"
  compression    = "LZ4"
  atime          = "OFF"
  sync           = "STANDARD"
  record_size    = "128K"
}

resource "truenas_dataset" "vm_data_disk" {
  pool           = "lab-storage"
  parent_dataset = "vm"
  name           = "data-disk"
  compression    = "LZ4"
  atime          = "OFF"
  sync           = "STANDARD"
  record_size    = "128K"
}

resource "truenas_dataset" "vm_img" {
  pool           = "lab-storage"
  parent_dataset = "vm"
  name           = "img"
  compression    = "LZ4"
  atime          = "OFF"
  sync           = "STANDARD"
  record_size    = "128K"
}
