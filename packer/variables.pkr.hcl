variable "iso_file" {
  type    = string
  default = null
}

variable "iso_checksum" {
  type    = string
  default = "none"
}

variable "memory_g" {
  type    = number
  default = 1
}

variable "disk_size_g" {
  type    = number
  default = 5
}

