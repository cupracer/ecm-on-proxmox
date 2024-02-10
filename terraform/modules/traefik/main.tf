resource "helm_release" "traefik" {
  name             = "traefik"
  chart            = "https://traefik.github.io/charts/traefik/traefik-${var.traefik_version}.tgz"
  namespace        = "traefik"
  create_namespace = true

  # don't wait, because without MetalLB config, this rollout won't finish
  wait             = false
  wait_for_jobs    = false
}

