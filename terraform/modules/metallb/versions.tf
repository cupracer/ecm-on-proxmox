terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.12.1"
    }
    ssh = {
      source = "loafoe/ssh"
      version = ">= 2.7.0"
    }
  }
}

