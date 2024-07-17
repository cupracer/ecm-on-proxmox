resource "ssh_resource" "setup_system_upgrade_controller" {
  host         = var.control_plane
  port         = 22
  user         = "root"
  private_key  = var.ssh_private_key

  pre_commands = [
    "mkdir -p /var/lib/rancher/${var.kubernetes_engine}/server/manifests",
  ]

  commands = [
    "curl -L -o /var/lib/rancher/${var.kubernetes_engine}/server/manifests/system-upgrade-controller.yaml https://github.com/rancher/system-upgrade-controller/releases/download/${var.system_upgrade_controller_version}/system-upgrade-controller.yaml",
    "curl -L -o /var/lib/rancher/${var.kubernetes_engine}/server/manifests/system-upgrade-controller-crd.yaml https://github.com/rancher/system-upgrade-controller/releases/download/${var.system_upgrade_controller_version}/crd.yaml",
  ]
}

