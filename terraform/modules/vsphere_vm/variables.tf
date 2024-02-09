variable "name" {
  type        = string
}

variable "description" {
  type = string
}

variable "fqdn" {
  type = string
}

variable "node_type" {
  type    = string
  default = null
}

variable "datacenter" {
  type = string
}

variable "compute_cluster" {
  type = string
}

variable "datastore" {
  type = string
}

variable "resource_pool" {
  type = string
}

variable "network_cluster" {
  type = string
}

variable "template" {
  type = string
}

variable "folder" {
  type = string
  default = ""
}

variable "cpus" {
  type = number
}

variable "memory_g" {
  type = number
}

variable "disk_size_g" {
  type = number
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

