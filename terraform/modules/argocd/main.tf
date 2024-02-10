resource "helm_release" "argocd" {
  name             = "argocd"
  chart            = "https://github.com/argoproj/argo-helm/releases/download/argo-cd-${var.argocd_chart_version}/argo-cd-${var.argocd_chart_version}.tgz"
  namespace        = "argocd"
  create_namespace = true

  # don't wait when using service.type="LoadBalancer", because without MetalLB config, this rollout won't finish
  wait             = var.service_type != "LoadBalancer" ? true : false
  wait_for_jobs    = var.service_type != "LoadBalancer" ? true : false

  values = [
    <<EOT
server:
  service:
    type: ${var.service_type}
  EOT
  ]
}

