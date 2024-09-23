locals {
  kured_control_plane_nodes = { for k, v in var.control_plane_nodes : k => v if length(var.control_plane_nodes) > 1 }
  kured_worker_nodes        = { for k, v in var.worker_nodes : k => v if length(var.worker_nodes) > 1 }
}

resource "ssh_resource" "kured_transactional_updates" {

  for_each     = merge(local.kured_control_plane_nodes, local.kured_worker_nodes)

  host         = each.value.public_ipv4_address
  bastion_host = var.bastion_host
  port         = 22
  user         = "root"
  private_key  = var.ssh_private_key

  pre_commands = [<<-EOT
    mkdir -p /etc/systemd/system/transactional-update.timer.d/
    EOT
  ]

  file {
    destination = "/etc/transactional-update.conf"
    owner = "root"
    group = "root"
    permissions = "0644"
    content = <<-EOT
      REBOOT_METHOD=kured
      EOT
  }

  commands = [
    "systemctl daemon-reload",
    "systemctl enable transactional-update.timer",
    "systemctl restart transactional-update.timer",
  ]
}

resource "helm_release" "kured" {
  depends_on = [ ssh_resource.kured_transactional_updates ]

  name             = "kured"
  chart            = "https://github.com/kubereboot/charts/releases/download/kured-${var.kured_chart_version}/kured-${var.kured_chart_version}.tgz"
  namespace        = "kube-system"
  create_namespace = true
  wait             = true
  wait_for_jobs    = true

  values = [
    <<EOT
configuration:
  period: "1h"
  startTime: "00:00"
  endTime: "23:59"
  timeZone: "Local"
  annotateNodes: true
  preRebootNodeLabels:
    - "kured=rebooting"
  postRebootNodeLabels:
    - "kured=done"
  tolerations: [{
    "key": "node-role.kubernetes.io/control-plane",
    "effect": "NoSchedule"
  }]
  EOT
  ]
}

