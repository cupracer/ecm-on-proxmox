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
  value = "TODO"
}

output "node_type" {
  value = var.node_type
}

output "cpu_sockets" {
  value = "TODO"
}

output "cpu_cores" {
  value = "TODO"
}

output "memory" {
  value = "TODO"
}

output "default_ipv4_address" {
  value = "TODO"
}

