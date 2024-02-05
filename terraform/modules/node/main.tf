module "vserver" {
  source                 = "../proxmox_vm"
  proxmox_node           = var.proxmox_node
  vm_name                = var.vm_name
  vm_description         = var.vm_description
  vm_template            = var.vm_template
  vm_cpu_sockets         = var.vm_cpu_sockets
  vm_cpu_cores           = var.vm_cpu_cores
  vm_memory              = var.vm_memory
  vm_disk_size           = var.vm_disk_size
  storage_pool           = var.storage_pool
  iso_storage_pool       = var.iso_storage_pool
  network_bridge         = var.network_bridge
  vm_root_public_keys    = var.root_public_keys
  ci_root_lock_password  = var.ci_root_lock_password
  ci_root_plain_password = var.ci_root_plain_password
  ssh_private_key        = var.ssh_private_key
}

output "vserver" {
  value = module.vserver
}

