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

output "server_type" {
  value = var.server_type
}

#output "cpu_cores" {
#  value = vsphere_virtual_machine.vm.num_cpus
#}

#output "memory" {
#  value = vsphere_virtual_machine.vm.memory
#}

output "subnet_id" {
  value = var.subnet_id
}

output "subnet_ip_range" {
  value = var.subnet_ip_range
}

output "public_ipv4_address" {
  value = hcloud_server.server.ipv4_address
}

output "private_ipv4_address" {
  value = hcloud_server_network.server.ip
}

output "cluster_ipv4_address" {
  value = hcloud_server_network.server.ip != "" ? hcloud_server_network.server.ip : hcloud_server.server.ipv4_address
}
