resource "rancher2_cluster_v2" "create_downstream_cluster" {
  name = lower(var.downstream_cluster_name)
  kubernetes_version = var.k3s_version

  rke_config {
    machine_global_config = <<EOF
disable:
  - servicelb
  - local-storage
EOF
  }
}

