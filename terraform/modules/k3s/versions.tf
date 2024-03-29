terraform {
  required_providers {
    ssh = {
      source = "loafoe/ssh"
      version = ">= 2.7.0"
    }
    random = {
      source = "hashicorp/random"
      version = ">= 3.6.0"
    }
    http = {
      source = "hashicorp/http"
      version = ">= 3.4.1"
    }
  }
}

