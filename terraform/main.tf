locals {
  root_public_keys = [ for key in try(split("\n", file(var.ci_root_authorized_keys_file)), []) : key if key != "" ]
  ssh_private_key  = file(var.ssh_private_key_file)
}

module "example1" {
  source                 = "./modules/node"
  proxmox_node           = var.proxmox_node
  vm_name                = "example1"
  vm_description         = "openSUSE MicroOS"
  vm_template            = "opensuse-microos"
  vm_cpu_sockets         = 1
  vm_cpu_cores           = 2
  vm_memory              = 2048
  vm_disk_size           = 20
  storage_pool           = var.storage_pool
  iso_storage_pool       = var.iso_storage_pool
  network_bridge         = var.network_bridge
  root_public_keys    = local.root_public_keys
  ci_root_lock_password  = var.ci_root_lock_password
  ci_root_plain_password = var.ci_root_plain_password
  ssh_private_key        = local.ssh_private_key
}

output "default_ipv4_address" {
  value = module.example1
}

