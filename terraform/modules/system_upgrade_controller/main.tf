resource "ssh_resource" "system_upgrade_controller" {
  host         = var.control_plane
  bastion_host = var.bastion_host
  port         = 22
  user         = "root"
  private_key  = var.ssh_private_key

  pre_commands = [<<-EOT
    mkdir -p /tmp/system_upgrade_controller
    chmod 700 /tmp/system_upgrade_controller
    EOT
  ]

  file {
    destination = "/tmp/system_upgrade_controller/kustomization.yaml"
    owner = "root"
    group = "root"
    permissions = "0644"
    content = templatefile("${path.module}/templates/kustomization.yaml.tftpl", {
      system_upgrade_controller_version = var.system_upgrade_controller_version
    })
  }

#  file {
#    destination = "/tmp/system_upgrade_controller/plan_control_plane.yaml"
#    owner = "root"
#    group = "root"
#    permissions = "0644"
#    content = templatefile("${path.module}/templates/plan_control_plane.yaml.tftpl", {
#      kubernetes_engine         = var.kubernetes_engine
#      kubernetes_engine_version = var.kubernetes_engine_version
#    })
#  }

#  file {
#    destination = "/tmp/system_upgrade_controller/plan_worker.yaml"
#    owner = "root"
#    group = "root"
#    permissions = "0644"
#    content = templatefile("${path.module}/templates/plan_worker.yaml.tftpl", {
#      kubernetes_engine         = var.kubernetes_engine
#      kubernetes_engine_version = var.kubernetes_engine_version
#    })
#  }

  commands = [
    "kubectl apply -k /tmp/system_upgrade_controller",
  ]
}
