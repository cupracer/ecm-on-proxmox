#output "vm" {
#  value = hcloud_server.server
#}

output "name" {
  value = hcloud_server.server.name
}

output "fqdn" {
  value = var.fqdn
}

#output "description" {
#  value = vsphere_virtual_machine.vm.annotation
#}

output "node_type" {
  value = var.node_type
}

#output "cpu_cores" {
#  value = vsphere_virtual_machine.vm.num_cpus
#}

#output "memory" {
#  value = vsphere_virtual_machine.vm.memory
#}

output "default_ipv4_address" {
  value = hcloud_server.server.ipv4_address
}

