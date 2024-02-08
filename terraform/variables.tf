variable "cluster_prefix" {
  type = string
}

variable "hostname_base" {
  type = string
  default = "cluster"
}

variable "dnsdomain" {
  type = string
}

variable "num_proxies" {
  type = number
}

variable "num_cluster_nodes" {
  type = number
}

variable "num_control_planes" {
  type = number
}

variable "root_ssh_private_key_file" {
  type = string
}

variable "root_authorized_keys_file" {
  type = string
}

variable "node_root_lock_password" {
  type = bool
}

variable "node_root_plain_password" {
  type      = string
  sensitive = true
}

