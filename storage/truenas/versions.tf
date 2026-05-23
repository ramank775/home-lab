terraform {
  required_version = ">= 1.5.0"

  required_providers {
    truenas = {
      source  = "PjSalty/truenas"
      version = "~> 1.10"
    }
  }

  backend "local" {
    path = "../../.lab/storage/truenas/terraform.tfstate"
  }
}
