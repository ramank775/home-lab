terraform {
  required_version = ">= 1.5.0"

  required_providers {
    opnsense = {
      source  = "browningluke/opnsense"
      version = ">= 0.13.0"
    }
  }

  backend "local" {
    path = "../../.lab/network/opnsense/terraform.tfstate"
  }
}
