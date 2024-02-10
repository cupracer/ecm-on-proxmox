resource "helm_release" "argocd" {
  name             = "argocd"
  chart            = "https://github.com/argoproj/argo-helm/releases/download/argo-cd-${var.argocd_version}/argo-cd-${var.argocd_version}.tgz"
  namespace        = "argocd"
  create_namespace = true
  wait             = true
  wait_for_jobs    = true

  values = [
    <<EOT
server:
  service:
    type: LoadBalancer
  EOT
  ]
}

