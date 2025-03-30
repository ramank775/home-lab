terraform {
  required_providers {
    postgresql = {
      source = "cyrilgdn/postgresql"
    }
    minio = {
      source  = "aminueza/minio"
    }
  }
}
