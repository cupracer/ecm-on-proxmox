variable "proxmox_url" {
  type    = string
  default = null
}

variable "proxmox_node" {
  type    = string
  default = null
}

variable "proxmox_username" {
  type    = string
  default = null
}

variable "proxmox_token" {
  type    = string
  default = null
}

variable "storage_pool" {
  type    = string
  default = null
}

variable "iso_storage_pool" {
  type    = string
  default = null
}

variable "network_bridge" {
  type    = string
  default = null
}

variable "iso_file" {
  type    = string
  default = null
}

variable "iso_checksum" {
  type    = string
  default = "none"
}

variable "cpu_cores" {
  type    = number
  default = 1
}

variable "memory" {
  type    = number
  default = 512
}

variable "disk_size" {
  type    = string
  default = "5G"
}

