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

variable "num_nodes" {
  type = number
}

variable "num_control_planes" {
  type = number
}

variable "root_authorized_keys_file" {
  type = string
}

