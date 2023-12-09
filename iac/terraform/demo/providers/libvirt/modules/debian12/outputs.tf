output "info" {
  value = var.dhcp ? libvirt_domain.debian12.network_interface.0.addresses.0 : data.template_file.meta_data.rendered
}
