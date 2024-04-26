variable "proxy_nodes" {
  type = map
}

variable "cluster_nodes" {
  type = map
}

variable "cluster_name" {
  type = string
}

variable "ssh_private_key" {
  type = string
}

variable "dnsmasq_servers" {
  type    = list(string)
  default = []
}

variable "dnsdomain" {
  type    = string
}

