terraform {
  required_providers {
    postgresql = {
      source = "cyrilgdn/postgresql"
    }
    proxmox = {
      source = "bpg/proxmox"
    }
    minio = {
      source = "aminueza/minio"
    }
  }
}