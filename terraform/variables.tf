variable "proxmox_api_url" {
  type = string
}

variable "proxmox_api_token_id" {
  type = string
  sensitive = true
}

variable "proxmox_api_token_secret" {
  type =  string
  sensitive = true
}

variable "proxmox_node" {
  type = string
}

variable "storage_pool" {
  type = string
}

variable "iso_storage_pool" {
  type = string
}

variable "network_bridge" {
  type = string
}

variable "ci_root_authorized_keys_file" {
  type = string
}

variable "ci_root_lock_password" {
  type = bool
}

variable "ci_root_plain_password" {
  type = string
#  sensitive = true
}
