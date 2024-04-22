output "nodes" {
  value = module.nodes
}

output "proxy_nodes" {
  value = { for i, n in module.nodes : i => n if n.node_type == "proxy" }
}

output "control_plane_nodes" {
  value = { for i, n in module.nodes : i => n if n.node_type == "control_plane" }
}

output "worker_nodes" {
  value = { for i, n in module.nodes : i => n if n.node_type == "worker" }
}

output "rancher_downstream_node_command" {
  value = length(module.rancher_downstream) > 0 ? nonsensitive(module.rancher_downstream[0].node_command) : null
}

output "rancher_downstream_node_command_insecure" {
  value = length(module.rancher_downstream) > 0 ? nonsensitive(module.rancher_downstream[0].node_command_insecure) : null
}

