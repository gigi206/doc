##################################################################################
# PLUGINS
##################################################################################

packer {
  required_plugins {
    qemu = {
      version = ">= 1.0.10"
      source  = "github.com/hashicorp/qemu"
    }
    # https://developer.hashicorp.com/packer/plugins/datasources/external
    external = {
      version = ">= 0.0.2"
      source  = "github.com/joomcode/external"
    }
    # https://developer.hashicorp.com/packer/plugins/datasources/sshkey
    # sshkey = {
    #   version = ">= 1.0.1"
    #   source = "github.com/ivoronin/sshkey"
    # }
    # https://developer.hashicorp.com/packer/integrations/hashicorp/ansible
    # ansible = {
    #   source  = "github.com/hashicorp/ansible"
    #   version = ">= 1.1.0"
    # }
    # https://developer.hashicorp.com/packer/plugins/datasources/git
    git = {
      source  = "github.com/ethanmdavidson/git"
      version = ">= 0.4.3"
    }
  }
}

##################################################################################
# VARIABLES
##################################################################################

# SSH

variable "ssh_username" {
  type    = string
  description = "The username to use to authenticate over SSH."
  default = ""
  sensitive = true
}

variable "ssh_password" {
  type    = string
  description = "The plaintext password to use to authenticate over SSH."
  default = ""
  sensitive = true
}

# ISO Objects

variable "iso_url" {
  type    = string
  description = "The url to retrieve the iso image"
  default = ""
  }

variable "iso_url_checksum" {
  type    = string
  description = "The url to retrieve the iso image checksum. Set `null` if `iso_checksum` is defined."
  default = ""
  }

variable "iso_checksum" {
  type    = string
  description = "The checksum of the ISO image."
  default = ""
}

variable "iso_checksum_type" {
  type    = string
  description = "The checksum type of the ISO image. Ex: sha256"
  default = ""
}

# Boot Settings

variable "data_source" {
  type        = string
  description = "The provisioning data source. One of `http` or `disk`."
}

variable "boot_command_custom" {
  type        = string
  description = "Add boot custom command ot the kernel."
}

# HTTP Endpoint

variable "http_directory" {
  type    = string
  description = "Directory of config files(user-data, meta-data)."
  default = ""
}

# Virtual Machine Settings

variable "vm_name" {
  type    = string
  description = "The template vm name"
  default = ""
}

variable "cd_label" {
  type    = string
  description = "The cd label device."
}

variable "vm_cpu" {
  type = number
  description = "The number of virtual CPUs."
}

variable "vm_mem_size" {
  type = number
  description = "The size for the virtual memory in MB."
}

variable "vm_disk_size" {
  type = string
  description = "The size for the virtual disk in MB."
}

variable "vm_boot_wait" {
  type = string
  description = "The time to wait before boot. "
  default = "1s"
}

# variable "shell_scripts" {
#   type = list(string)
#   description = "A list of scripts."
#   default = []
# }

##################################################################################
# DATA SOURCE
##################################################################################

data "http" "iso_checksum" {
  url = var.iso_url_checksum
}

data "git-repository" "cwd" {}

# data "external-raw" "openssl_salt" {
#   program = ["openssl", "rand", "-base64", "6"]
# }

# data "external-raw" "password_encrypted" {
#   # program = ["${var.ssh_password}", "|", "openssl", "passwd", "-6", "-salt", "${data.external-raw.openssl_salt.result}", "-stdin"]
#   program = ["openssl", "passwd", "-6", "-salt", "${data.external-raw.openssl_salt.result}", "-stdin"]
#   query = "${var.ssh_password}"
# }

##################################################################################
# LOCALS
##################################################################################

locals {
  buildtime                 = formatdate("YYYY-MM-DD hh:mm ZZZ", timestamp())
  build_version             = data.git-repository.cwd.head
  iso_checksum              = var.iso_checksum == null ? split(" ", data.http.iso_checksum.body)[0] : var.iso_checksum
  # build_password_encrypted  = replace(data.external-raw.password_encrypted.result, "\n", "")
  # Cf https://doc.opensuse.org/documentation/leap/autoyast/single-html/book-autoyast/index.html
  data_source_command       = var.data_source == "http" ? " autoyast=http://{{ .HTTPIP }}:{{ .HTTPPort }}/autoinst.xml" : " autoyast=label://${var.cd_label}/autoinst.xml"
  # data_source_command = var.data_source == "http" ? " autoyast=http://{{ .HTTPIP }}:{{ .HTTPPort }}/autoinst.xml" : " autoyast=device://sr1/autoinst.xml"
  data_source_content       = {
    "/autoinst.xml" = templatefile("${abspath(path.root)}/data/autoinst.pkrtpl.hcl", {
      build_username            = "${var.ssh_username}"
      build_password_encrypted  = "${var.ssh_password}"
      # build_password_encrypted  = "${local.build_password_encrypted}"
    })
  }
}

##################################################################################
# SOURCE
##################################################################################
# https://developer.hashicorp.com/packer/integrations/hashicorp/qemu/latest/components/builder/qemu
source "qemu" "opensuse15-sp5" {
  iso_url                 = var.iso_url
  iso_checksum            = local.iso_checksum
  cd_label                = var.cd_label
  http_content            = var.data_source == "http" ? local.data_source_content : null
  cd_content              = var.data_source == "disk" ? local.data_source_content : null
  http_directory          = var.http_directory
  output_directory        = "build"
  # qemu_binary             = "/usr/bin/kvm" # /usr/bin/qemu-system-x86_64
  disk_size               = var.vm_disk_size
  cpus                    = var.vm_cpu
  # display                 = "gtk"
  # disk_discard            = "unmap"
  # disk_cache              = null
  # disk_compression        = true
  format                  = "qcow2"
  vm_name                 = "${var.vm_name}.qcow"
  accelerator             = "kvm"
  ssh_password            = var.ssh_password
  ssh_username            = var.ssh_username
  ssh_port                = 22
  ssh_timeout             = "90m"
  # ssh_handshake_attempts  = "100"
  shutdown_command        = "echo '${var.ssh_password}' | sudo -S -E shutdown -P now"
  shutdown_timeout        = "15m"
  # ssh_pty                 = true
  net_device              = "virtio-net"
  disk_interface          = "virtio"
  boot_wait               = var.vm_boot_wait
  memory                  = var.vm_mem_size
  # https://developer.hashicorp.com/packer/integrations/hashicorp/qemu/latest/components/builder/qemu#boot-configuration
  boot_command        = [
    "<down>",
    "biosdevname=0 ",
    "net.ifnames=0 ",
    "netdevice=eth0 ",
    "netsetup=dhcp ",
    "lang=fr_FR ",
    # "textmode=1 ",
    "${local.data_source_command}",
    "${var.boot_command_custom}",
    "<enter>",
  ]
  # qemuargs            = [
  #   # [
  #   #   "-display",
  #   #   "gtk"
  #   # ],
  #   # [
  #   #   "-machine",
  #   #   "accel=kvm"
  #   # ],
  #   # [
  #   #   "-m",
  #   #   "${var.vm_mem_size}"
  #   # ],
  #   # [
  #   #   "-smp",
  #   #   "${var.vm_cpu}"
  #   # ]
  # ]
}

##################################################################################
# BUILD
##################################################################################

build {
  sources = ["source.qemu.opensuse15-sp5"]

  # provisioner "ansible" {
  #   galaxy_file            = "${path.cwd}/ansible/requirements.yml"
  #   galaxy_force_with_deps = true
  #   playbook_file          = "${path.cwd}/ansible/main.yml"
  #   roles_path             = "${path.cwd}/ansible/roles"
  #   ansible_env_vars = [
  #     "ANSIBLE_CONFIG=${path.cwd}/ansible/ansible.cfg",
  #     "ANSIBLE_PYTHON_INTERPRETER=/usr/bin/python3"
  #   ]
  #   extra_arguments = [
  #     "--extra-vars", "display_skipped_hosts=false",
  #     "--extra-vars", "BUILD_USERNAME=${var.build_username}",
  #     "--extra-vars", "BUILD_KEY='${var.build_key}'",
  #     "--extra-vars", "ANSIBLE_USERNAME=${var.ansible_username}",
  #     "--extra-vars", "ANSIBLE_KEY='${var.ansible_key}'",
  #   ]
  # }

  # post-processor "manifest" {
  #   output     = "${local.manifest_path}${local.manifest_date}.json"
  #   strip_path = true
  #   strip_time = true
  #   custom_data = {
  #     ansible_username         = var.ansible_username
  #     build_username           = var.build_username
  #     build_date               = local.build_date
  #     build_version            = local.build_version
  #     common_data_source       = var.common_data_source
  #     common_vm_version        = var.common_vm_version
  #     vm_cpu_cores             = var.vm_cpu_cores
  #     vm_cpu_count             = var.vm_cpu_count
  #     vm_disk_size             = var.vm_disk_size
  #     vm_disk_thin_provisioned = var.vm_disk_thin_provisioned
  #     vm_firmware              = var.vm_firmware
  #     vm_guest_os_type         = var.vm_guest_os_type
  #     vm_mem_size              = var.vm_mem_size
  #     vm_network_card          = var.vm_network_card
  #     vsphere_cluster          = var.vsphere_cluster
  #     vsphere_host             = var.vsphere_host
  #     vsphere_datacenter       = var.vsphere_datacenter
  #     vsphere_datastore        = var.vsphere_datastore
  #     vsphere_endpoint         = var.vsphere_endpoint
  #     vsphere_folder           = var.vsphere_folder
  #   }
  # }
}
