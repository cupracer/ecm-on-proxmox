locals {
  sanitized_ip_range = replace(var.address_range, "/[^0-9]/", "-")
  pool_name = "${var.l2advertisement_name}-${local.sanitized_ip_range}"
}

resource "helm_release" "metallb" {
  name             = "metallb"
  chart            = "https://github.com/metallb/metallb/releases/download/metallb-chart-${var.metallb_chart_version}/metallb-${var.metallb_chart_version}.tgz"
  namespace        = "metallb-system"
  create_namespace = true
  wait             = true
  wait_for_jobs    = true

  values = [
    <<EOT
controller:
  tolerations:
    - key: "node-role.kubernetes.io/control-plane"
      operator: "Exists"
      effect: "NoSchedule"
  EOT
  ]
}

resource "ssh_resource" "setup_address_range" {
  depends_on = [ helm_release.metallb ]

  host         = var.control_plane
  bastion_host = var.bastion_host
  port         = 22
  user         = "root"
  private_key  = var.ssh_private_key

  pre_commands = [
    "mkdir -p /var/lib/rancher/${var.kubernetes_engine}/server/manifests",
  ]

  file {
    destination = "/var/lib/rancher/${var.kubernetes_engine}/server/manifests/metallb-config.yaml"
    owner = "root"
    group = "root"
    permissions = "0640"
    content = templatefile("${path.module}/metallb-config.yaml.tftpl", {
      pool_name = local.pool_name,
      address_range = var.address_range,
      l2advertisement_name = var.l2advertisement_name,
    })
  }
}

