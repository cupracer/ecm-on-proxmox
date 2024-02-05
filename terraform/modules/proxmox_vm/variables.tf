variable "proxmox_node" {
  type = string
}

variable "vm_name" {
  type = string
}

variable "vm_description" {
  type = string
}

variable "vm_template" {
  type = string
}

variable "vm_cpu_sockets" {
  type = number
}

variable "vm_cpu_cores" {
  type = number
}

variable "vm_memory" {
  type = number
}

variable "vm_disk_size" {
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

variable "vm_root_public_keys" {
  type = list(string)
}

variable "ci_root_lock_password" {
  type = bool
}

variable "ci_root_plain_password" {
  type = string
#  sensitive = true
}

variable "ssh_private_key" {
  type = string
#  sensitive = true
}

