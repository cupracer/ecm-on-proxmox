resource "helm_release" "metallb" {
  name             = "metallb"
  chart            = "https://github.com/metallb/metallb/releases/download/metallb-chart-${var.metallb_version}/metallb-${var.metallb_version}.tgz"
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

