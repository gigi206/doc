# https://registry.terraform.io/providers/dmacvicar/libvirt/latest/docs

terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.7.6"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

data "template_file" "user_data" {
  template = file("${path.module}/data/cloud_init.cfg")
}

data "template_file" "meta_data" {
  template = file("${path.module}/data/network_interfaces.cfg")
    vars = {
    ip = var.ip
  }
}

resource "libvirt_cloudinit_disk" "commoninit" {
  name      = "commoninit.iso"
  user_data = data.template_file.user_data.rendered
  meta_data = var.dhcp ? null : data.template_file.meta_data.rendered
}

resource "libvirt_volume" "debian12-qcow2" {
  name    = "debian12.qcow2"
  pool    = "default"
  format  = "qcow2"
  source  = "https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-generic-amd64.qcow2"
  # source  = "https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-nocloud-amd64.qcow2"
  # source  = "https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-genericcloud-amd64.qcow2"
}

resource "libvirt_domain" "debian12" {
  name      = var.name
  memory    = var.memory
  vcpu      = var.cpu
  cloudinit = libvirt_cloudinit_disk.commoninit.id

  network_interface {
    network_name    = var.libvirt_network_name
    wait_for_lease  = var.dhcp ? true : false
    # mac           = "52:54:00:AE:8C:E8"
  }

  disk {
    volume_id = libvirt_volume.debian12-qcow2.id
  }

  console {
    type        = "pty"
    target_type = "serial"
    target_port = "0"
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}
