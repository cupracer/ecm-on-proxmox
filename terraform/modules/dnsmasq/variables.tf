variable "proxy_nodes" {
  type = map
}

variable "ssh_private_key" {
  type = string
}

variable "parent_dns" {
  type    = list(string)
  default = []
}

