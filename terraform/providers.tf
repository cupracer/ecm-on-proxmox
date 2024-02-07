provider "proxmox" {
  pm_api_url          = var.proxmox_api_url
  pm_api_token_id     = var.proxmox_api_token_id
  pm_api_token_secret = var.proxmox_api_token_secret
  pm_tls_insecure     = false

  pm_log_enable = false

  pm_log_levels = {
    _default    = "debug"
    _capturelog = ""
  }
}

