module "node" {
  source                 = "../proxmox_vm"

  proxmox_node           = var.proxmox_node
  name                   = var.vm_name
  description            = var.vm_description
  template               = var.vm_template
  cpu_sockets            = var.vm_cpu_sockets
  cpu_cores              = var.vm_cpu_cores
  memory                 = var.vm_memory
  disk_size              = var.vm_disk_size
  storage_pool           = var.storage_pool
  iso_storage_pool       = var.iso_storage_pool
  network_bridge         = var.network_bridge
  root_public_keys       = var.root_public_keys
  ci_root_lock_password  = var.ci_root_lock_password
  ci_root_plain_password = var.ci_root_plain_password
}

