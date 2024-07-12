variable "proxmox_node" {
  type = string
}

variable "name" {
  type = string
}

variable "fqdn" {
  type = string
}

variable "description" {
  type = string
}

variable "node_type" {
  type    = string
  default = null
}

variable "template" {
  type = string
}

variable "cpu_cores" {
  type = number
}

variable "memory" {
  type = number
}

variable "disk_size" {
  type = number
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

variable "root_public_keys" {
  type = list(string)
}

variable "ci_root_lock_password" {
  type = bool
}

variable "ci_root_plain_password" {
  type = string
  sensitive = true
}

variable "vm_start_onboot" {
  type    = bool
}

