locals {
  rancher_bootstrap_password = random_string.rancher_bootstrap_password.result
}

resource "random_string" "rancher_bootstrap_password" {
  length  = 32
  upper   = true
  special = true
}

resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  chart            = "https://charts.jetstack.io/charts/cert-manager-v${var.cert_manager_chart_version}.tgz"
  namespace        = "cert-manager"
  create_namespace = true
  wait             = true
  wait_for_jobs    = true

  set {
    name  = "installCRDs"
    value = "true"
  }
}

resource "helm_release" "rancher_server" {
  depends_on = [ helm_release.cert_manager, ]

  name             = "rancher"
  chart            = var.rancher_chart_url
  namespace        = "cattle-system"
  create_namespace = true
  wait             = true
  wait_for_jobs    = true

  set {
    name  = "hostname"
    value = lower(var.cluster_fqdn)
  }

  set {
    name  = "replicas"
    value = length(var.control_plane_nodes)
  }

  set {
    # TODO: change this once the terraform provider has been updated with the new pw bootstrap logic
    name  = "bootstrapPassword"
    value = local.rancher_bootstrap_password
  }
}

resource "rancher2_bootstrap" "admin" {
  depends_on = [ helm_release.rancher_server, ]

  initial_password = local.rancher_bootstrap_password
  password         = var.rancher_password
  telemetry        = false
}

