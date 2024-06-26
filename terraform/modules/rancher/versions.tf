terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.12.1"
    }
    rancher2 = {
      source = "rancher/rancher2"
      version = ">= 4.0.0"
    }
    ssh = {
      source = "loafoe/ssh"
      version = ">= 2.7.0"
    }
  }
}

