# https://registry.terraform.io/providers/dmacvicar/libvirt/latest/docs

terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.7.6"
    }
    validation = {
        source = "tlkamp/validation"
        version = "1.0.0"
    }
  }
}

provider "validation" {}

provider "libvirt" {
  uri = "qemu:///system"
}

data "external" "is_ip_in_network" {
  program = ["python3", "-c", "import ipaddress, json; print(json.dumps({'key': str(ipaddress.IPv4Address('${var.virtual_machine.ip}') in ipaddress.IPv4Network('${libvirt_network.mynetwork.addresses.0}'))}));"]
}

resource "validation_error" "check_ip" {
  condition = var.virtual_machine.dhcp == false && ! tobool(lower(data.external.is_ip_in_network.result.key))
  summary = "IP var.virtual_machine.ip in not in the range of the newtwork libvirt_network.mynetwork.addresses.0"
  details = <<EOF
Please use differing values for these inputs:
var.virtual_machine.ip                : ${var.virtual_machine.ip}
libvirt_network.mynetwork.addresses.0 : ${libvirt_network.mynetwork.addresses.0}
EOF
}

resource "libvirt_network" "mynetwork" {
  name      = "mynetwork"
  mode      = "nat"
  domain    = "mynetwork.local"
  addresses = ["192.168.100.0/24"]
  dhcp {
    enabled = var.dhcp ? true : false
  }
  # xml {
  #   xslt = templatefile("${abspath(path.root)}/data/mynetwork.xsl", {
  #     name          = "mynetwork"
  #     ip            = var.network_ip
  #     mac           = var.network_mac
  #     uuid          = uuid()
  #     servername    = libvirt_domain.debian12.name
  #   })
  # }
}

# https://support.hashicorp.com/hc/en-us/articles/21807317486995-Error-Module-is-incompatible-with-count-for-each-and-depends-on
# Warning: Module is incompatible with count, for_each, and depends_on
module "debian12" {
  # Terraform does not support loop on module
  source                = "./modules/debian12"
  name                  = var.virtual_machine.name
  ip                    = var.virtual_machine.ip
  cpu                   = var.virtual_machine.cpu
  memory                = var.virtual_machine.memory
  dhcp                  = var.virtual_machine.dhcp
  libvirt_network_name  = libvirt_network.mynetwork.name
}

output "info" {
  value = module.debian12
  # value = module.debian12.info
}
