#output "vm" {
#  value = vsphere_virtual_machine.vm
#}

output "name" {
  value = vsphere_virtual_machine.vm.name
}

output "fqdn" {
  value = var.fqdn
}

output "description" {
  value = vsphere_virtual_machine.vm.annotation
}

output "node_type" {
  value = var.node_type
}

output "cpu_cores" {
  value = vsphere_virtual_machine.vm.num_cpus
}

output "memory" {
  value = vsphere_virtual_machine.vm.memory
}

output "default_ipv4_address" {
  value = vsphere_virtual_machine.vm.default_ip_address
}

output "private_ipv4_address" {
  # TODO: implement private IPv4
  value = ""
}

output "cluster_ipv4_address" {
  # TODO: implement private IPv4
  value = vsphere_virtual_machine.vm.default_ip_address
}
