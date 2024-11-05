variable "name" {
  type        = string
}

variable "microos_snapshot_id" {
  type        = string
}

variable "server_type" {
  type        = string
}

variable "location" {
  type        = string
}

variable "ssh_keys" {
  type        = list(string)
}

#variable "description" {
#  type = string
#}

variable "fqdn" {
  type = string
}

variable "node_type" {
  type    = string
  default = null
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

variable "backups" {
  type = bool
}

variable "network_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "subnet_ip_range" {
  type = string
}

variable "seq_no" {
  type = number
}

variable "public_ipv4_enabled" {
  type = bool
}

