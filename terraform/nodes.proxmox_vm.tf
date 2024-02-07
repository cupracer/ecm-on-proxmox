provider "proxmox" {
  pm_api_url          = var.proxmox_api_url
  pm_api_token_id     = var.proxmox_api_token_id
  pm_api_token_secret = var.proxmox_api_token_secret
  pm_tls_insecure     = var.proxmox_tls_insecure

  pm_log_enable = false

  pm_log_levels = {
    _default    = "debug"
    _capturelog = ""
  }
}


locals {
  proxmox_node           = var.proxmox_node
  storage_pool           = var.proxmox_storage_pool
  iso_storage_pool       = var.proxmox_iso_storage_pool
  network_bridge         = var.proxmox_network_bridge
  ci_root_lock_password  = var.proxmox_ci_root_lock_password
  ci_root_plain_password = var.proxmox_ci_root_plain_password 
}


module "nodes" {
  source                 = "./modules/proxmox_vm"
  for_each               = local.cluster_nodes_map

  proxmox_node           = local.proxmox_node
  template               = "opensuse-microos"
  description            = "openSUSE MicroOS - Cluster ${local.cluster_name}"

  name                   = each.key
  fqdn                   = each.value.fqdn
  node_type              = each.value.node_type
  cpu_sockets            = each.value.cpu_sockets
  cpu_cores              = each.value.cpu_cores
  memory                 = each.value.memory_m
  disk_size              = each.value.disk_size_gb

  storage_pool           = local.storage_pool
  iso_storage_pool       = local.iso_storage_pool
  network_bridge         = local.network_bridge
  root_public_keys       = local.root_public_keys
  ci_root_lock_password  = local.ci_root_lock_password
  ci_root_plain_password = local.ci_root_plain_password
}

variable "proxmox_api_url" {
  type = string
}

variable "proxmox_api_token_id" {
  type = string
  sensitive = true
}

variable "proxmox_api_token_secret" {
  type = string
  sensitive = true
}

variable "proxmox_tls_insecure" {
  type = bool
}

variable "proxmox_node" {
  type = string
}

variable "proxmox_storage_pool" {
  type = string
}

variable "proxmox_iso_storage_pool" {
  type = string
}

variable "proxmox_network_bridge" {
  type = string
}

variable "proxmox_ci_root_lock_password" {
  type = bool
}

variable "proxmox_ci_root_plain_password" {
  type = string
  sensitive = true
}

