terraform {
  required_providers {
    ssh = {
      source = "loafoe/ssh"
      version = "2.6.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.9.0"
    }
  }
}

