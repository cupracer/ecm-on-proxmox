#output "vm" {
#  value = proxmox_vm_qemu.vm
#}

output "name" {
  value = proxmox_vm_qemu.vm.name
}

output "fqdn" {
  value = var.fqdn
}

output "description" {
  value = proxmox_vm_qemu.vm.desc
}

output "node_type" {
  value = var.node_type
}

output "cpu_cores" {
  value = proxmox_vm_qemu.vm.cores
}

output "memory" {
  value = proxmox_vm_qemu.vm.memory
}

output "default_ipv4_address" {
  value = proxmox_vm_qemu.vm.default_ipv4_address
}

output "private_ipv4_address" {
  # TODO: implement private IPv4
  value = ""
}

output "cluster_ipv4_address" {
  # TODO: implement private IPv4
  value = proxmox_vm_qemu.vm.default_ipv4_address
}
