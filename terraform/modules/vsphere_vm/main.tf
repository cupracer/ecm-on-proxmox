locals {
  name = var.name
  datacenter = var.datacenter
  compute_cluster = var.compute_cluster
  datastore = var.datastore
  resource_pool = var.resource_pool
  network_cluster = var.network_cluster
  template = var.template
  folder = "vm/${var.folder}"
  cpus = var.cpus
  memory_g = var.memory_g
  disk_size_g = var.disk_size_g

  root_public_keys             = var.root_public_keys
  ci_root_lock_password        = var.ci_root_lock_password
  ci_root_plain_password       = var.ci_root_plain_password
}

data "vsphere_datacenter" "datacenter" {
  name = local.datacenter
}

data "vsphere_compute_cluster" "compute_cluster" {
  name = local.compute_cluster
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_datastore" "datastore" {
  name = local.datastore
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_resource_pool" "default" {
  name          = local.resource_pool
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_network" "network_cluster" {
  name = local.network_cluster
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_virtual_machine" "template" {
  name          = local.template
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

#data "cloudinit_config" "meta_data" {
#  gzip          = false
#  base64_encode = true
#
#  part {
#    filename     = "metadata.yaml"
#    content_type = "text/cloud-config"
#
#    content = templatefile("${path.module}/ci_meta_data.yaml.tftpl", {
#      instance_id = sha1(local.name),
#      hostname = local.name,
#    })
#  }
#}

data "cloudinit_config" "user_data" {
  gzip          = false
  base64_encode = true

  part {
    filename     = "userdata.yaml"
    content_type = "text/cloud-config"

    content = templatefile("${path.module}/ci_user_data.yaml.tftpl", {
      root_public_keys = local.root_public_keys,
      root_lock_password = local.ci_root_lock_password,
      root_plain_password = local.ci_root_plain_password
    })
  }
}

resource "vsphere_virtual_machine" "vm" {
  name             = local.name
  resource_pool_id = data.vsphere_resource_pool.default.id
  datastore_id     = data.vsphere_datastore.datastore.id
  folder           = local.folder

  guest_id = data.vsphere_virtual_machine.template.guest_id

  num_cpus = local.cpus
  memory = local.memory_g * 1024

  network_interface {
    network_id   = data.vsphere_network.network_cluster.id
    adapter_type = "vmxnet3"
  }

  disk {
    label = "disk0"
    size  = local.disk_size_g
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
  }

  extra_config = {
#    "guestinfo.metadata.encoding" = "base64"
#    "guestinfo.metadata"          = data.cloudinit_config.meta_data.rendered
    "guestinfo.userdata.encoding" = "base64"
    "guestinfo.userdata"          = data.cloudinit_config.user_data.rendered
  }
}

