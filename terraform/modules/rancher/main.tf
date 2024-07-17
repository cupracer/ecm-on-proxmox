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

resource "ssh_resource" "install_ca_data" {
  depends_on = [ helm_release.cert_manager, ]

  count = var.ca_key_path != null && var.ca_cert_path != null ? 1 : 0

  host         = var.control_plane
  port         = 22
  user         = "root"
  private_key  = var.ssh_private_key

  pre_commands = [
    "mkdir -p /var/lib/rancher/${var.kubernetes_engine}/server/manifests",
  ]

  file {
    destination = "/var/lib/rancher/${var.kubernetes_engine}/server/manifests/cert-manager-ca-data.yaml"
    owner = "root"
    group = "root"
    permissions = "0640"
    content = templatefile("${path.module}/cert-manager-ca-data.yaml.tftpl", {
      cert_data = filebase64(var.ca_cert_path),
      key_data = filebase64(var.ca_key_path),
    })
  }
}

resource "ssh_resource" "install_rancher_tls" {
  depends_on = [ ssh_resource.install_ca_data, ]

  count = var.ca_key_path != null && var.ca_cert_path != null ? 1 : 0

  host         = var.control_plane
  port         = 22
  user         = "root"
  private_key  = var.ssh_private_key

  pre_commands = [
    "mkdir -p /var/lib/rancher/${var.kubernetes_engine}/server/manifests",
  ]

  file {
    destination = "/var/lib/rancher/${var.kubernetes_engine}/server/manifests/rancher-tls-data.yaml"
    owner = "root"
    group = "root"
    permissions = "0640"
    content = templatefile("${path.module}/rancher-tls-data.yaml.tftpl", {
      cacert_data = filebase64(var.ca_cert_path),
      fqdn = lower(var.cluster_fqdn),
    })
  }
}

resource "helm_release" "rancher_server" {
  depends_on = [ ssh_resource.install_rancher_tls, ]

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
    name  = "ingress.tls.source"
    value = var.ca_key_path != null && var.ca_cert_path != null ? "secret" : "rancher"
  }

  set {
    name  = "privateCA"
    value = var.ca_key_path != null && var.ca_cert_path != null ? true : false
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

data "http" "wait_for_rancher" {
  depends_on = [helm_release.rancher_server, ]

  #url            = format("%s/healthz", aws_eks_cluster.this[0].endpoint)
  url            = "${local.rancher_url}/ping"
  insecure       = true
  #ca_certificate = base64decode(local.cluster_auth_base64)
  
  retry {
    attempts     = 9
    min_delay_ms = 30000
    max_delay_ms = 60000
  }
}

resource "rancher2_bootstrap" "admin" {
  depends_on = [ data.http.wait_for_rancher, ]

  initial_password = local.rancher_bootstrap_password
  password         = var.rancher_password
  telemetry        = false
}
