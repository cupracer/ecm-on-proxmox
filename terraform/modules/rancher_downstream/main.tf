locals {
  cluster_fqdn = lower(var.cluster_fqdn)
}

resource "rancher2_cluster_v2" "create_downstream_cluster" {
  name = lower(var.downstream_cluster_name)
  kubernetes_version = var.kubernetes_engine_version

  rke_config {
    machine_global_config = <<EOF
disable:
  - servicelb
  - local-storage
  - traefik
  - rke2-ingress-nginx
tls-san: [ ${local.cluster_fqdn} ]
EOF
  }

  local_auth_endpoint {
    enabled = true
    fqdn = local.cluster_fqdn

  }
}
