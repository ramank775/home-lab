// Datasets are imported by their full path `<pool>/<dataset>` (with all
// parent segments). NFS shares are imported by their numeric ID.

# k3s parent datasets
import {
  to = module.k3s.truenas_dataset.k3s
  id = "lab-storage/k3s"
}
import {
  to = module.k3s.truenas_dataset.k3s_nfs_vol
  id = "lab-storage/k3s/nfs-vol"
}
import {
  to = module.k3s.truenas_dataset.k3s_vols
  id = "lab-storage/k3s/vols"
}
import {
  to = module.k3s.truenas_dataset.k3s_snaps
  id = "lab-storage/k3s/snaps"
}

# minio
import {
  to = module.minio.truenas_dataset.minio
  id = "lab-storage/minio"
}
import {
  to = module.minio.truenas_dataset.minio_data
  id = "lab-storage/minio/data"
}
import {
  to = module.minio.truenas_dataset.minio_export
  id = "lab-storage/minio/export"
}

# Proxmox-backing storage
import {
  to = module.pve_storage.truenas_dataset.vm
  id = "lab-storage/vm"
}
import {
  to = module.pve_storage.truenas_dataset.vm_boot_disk
  id = "lab-storage/vm/boot-disk"
}
import {
  to = module.pve_storage.truenas_dataset.vm_data_disk
  id = "lab-storage/vm/data-disk"
}
import {
  to = module.pve_storage.truenas_dataset.vm_img
  id = "lab-storage/vm/img"
}

# wp-serverless
import {
  to = module.wp_serverless.truenas_dataset.wp_serverless
  id = "lab-storage/wp-serverless"
}
import {
  to = module.wp_serverless.truenas_dataset.storage
  id = "lab-storage/wp-serverless/storage"
}
import {
  to = module.wp_serverless.truenas_share_nfs.storage
  id = "7"
}

# mail
import {
  to = module.mail.truenas_dataset.mail
  id = "personal/mail"
}

# nextcloud
import {
  to = module.nextcloud.truenas_dataset.nextcloud
  id = "personal/nextcloud"
}
import {
  to = module.nextcloud.truenas_share_nfs.nextcloud
  id = "6"
}
