output "node" {
  value = module.node.vm
}

output "name" {
  value = module.node.vm.name
}

output "fqdn" {
  value = var.fqdn
}

output "description" {
  value = module.node.vm.desc
}

output "node_type" {
  value = var.node_type
}

output "cpu_sockets" {
  value = module.node.vm.sockets
}

output "cpu_cores" {
  value = module.node.vm.cores
}

output "memory" {
  value = module.node.vm.memory
}

output "default_ipv4_address" {
  value = module.node.vm.default_ipv4_address
}

