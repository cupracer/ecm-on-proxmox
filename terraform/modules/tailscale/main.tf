resource "ssh_resource" "tailscale" {
  host        = var.primary_master_host
  bastion_host = var.bastion_host
  port         = 22
  user         = "root"
  private_key  = var.ssh_private_key

  pre_commands = [<<-EOT
    mkdir -p /tmp/tailscale
    chmod 700 /tmp/tailscale
    EOT
  ]

  file {
    destination = "/tmp/tailscale/kustomization.yaml"
    owner = "root"
    group = "root"
    permissions = "0644"
    content = templatefile("${path.module}/templates/kustomization.yaml.tftpl", {
      files = [
        "namespace.yaml",
        "operator.yaml",
        "clusterrolebinding.yaml",
      ]
    })
  }

  file {
    destination = "/tmp/tailscale/namespace.yaml"
    owner = "root"
    group = "root"
    permissions = "0644"
    content = templatefile("${path.module}/templates/namespace.yaml.tftpl", {})
  }

  file {
    destination = "/tmp/tailscale/operator.yaml"
    owner = "root"
    group = "root"
    permissions = "0644"
    content = templatefile("${path.module}/templates/operator.yaml.tftpl", {
      tailscale_oauth_client_id     = var.tailscale_oauth_client_id,
      tailscale_oauth_client_secret = var.tailscale_oauth_client_secret,
      cluster_name = var.cluster_name
    })
  }

  file {
    destination = "/tmp/tailscale/clusterrolebinding.yaml"
    owner = "root"
    group = "root"
    permissions = "0644"
    content = templatefile("${path.module}/templates/clusterrolebinding.yaml.tftpl", {
      tailscale_user = var.tailscale_user
    })
  }

  commands = [
    "kubectl apply -k /tmp/tailscale",
  ]
}

resource "ssh_resource" "tailscale_ingress_rancher" {
  depends_on = [ ssh_resource.tailscale ]
  host        = var.primary_master_host
  bastion_host = var.bastion_host
  port         = 22
  user         = "root"
  private_key  = var.ssh_private_key

  pre_commands = [<<-EOT
    mkdir -p /tmp/tailscale_ingress_rancher
    chmod 700 /tmp/tailscale_ingress_rancher
    EOT
  ]

  file {
    destination = "/tmp/tailscale_ingress_rancher/kustomization.yaml"
    owner = "root"
    group = "root"
    permissions = "0644"
    content = templatefile("${path.module}/templates/kustomization.yaml.tftpl", {
      files = [
        "ingress-rancher.yaml",
      ]
    })
  }

  file {
    destination = "/tmp/tailscale_ingress_rancher/ingress-rancher.yaml"
    owner = "root"
    group = "root"
    permissions = "0644"
    content = templatefile("${path.module}/templates/ingress-rancher.yaml.tftpl", {
      cluster_name = var.cluster_name
    })
  }

  commands = [
    "kubectl apply -k /tmp/tailscale_ingress_rancher",
  ]
}
