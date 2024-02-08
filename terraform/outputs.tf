output "nodes" {
  value = module.nodes
}

output "control_plane_nodes" {
  value = { for i, n in module.nodes : i => n if n.node_type == "control_plane" }
}

output "worker_nodes" {
  value = { for i, n in module.nodes : i => n if n.node_type == "worker" }
}

