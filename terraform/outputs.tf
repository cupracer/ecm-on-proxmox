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

