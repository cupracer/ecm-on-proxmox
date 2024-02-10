terraform {
  required_providers {
    ssh = {
      source = "loafoe/ssh"
      version = "2.7.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.12.1"
    }
  }
}

