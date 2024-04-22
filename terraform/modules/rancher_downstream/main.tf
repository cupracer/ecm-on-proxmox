resource "rancher2_cluster_v2" "create_downstream_cluster" {
  name = var.downstream_cluster_name
  kubernetes_version = var.k3s_version
}

