packer {
  required_plugins {
    qemu = {
      version = ">= 1.0.10"
      source  = "github.com/hashicorp/qemu"
    }
    # sshkey = {
    #   version = ">= 1.0.1"
    #   source = "github.com/ivoronin/sshkey"
    # }
    # ansible = {
    #   source  = "github.com/hashicorp/ansible"
    #   version = ">= 1.1.0"
    # }
    # git = {
    #   source  = "github.com/ethanmdavidson/git"
    #   version = ">= 0.4.3"
    # }
  }
}

locals {
  data_source_content = {
    "/autoinst.xml" = templatefile("${abspath(path.root)}/data/autoinst.pkrtpl.hcl", {
      build_password_encrypted = "$6$bxkRE0QFnkOmZ.Vn$wF3BOHVIYzcb4nVMJEKm1D3d45Nf0bV84J82Gs7lM0c1UvpByiB26qpxm3g/v/QjF7ylJDMKOCndGy.HZHRZr1"
      scc_email                = "gigix001@yopmail.com"
      scc_code                 = "62DD2B70C460163B"
    })
  }
}

# https://developer.hashicorp.com/packer/integrations/hashicorp/qemu/latest/components/builder/qemu
source "qemu" "sles15-sp5" {
    iso_url             = "file:///home/gigi/Téléchargements/SLE-15-SP5-Full-x86_64-GM-Media1.iso"
    iso_checksum        = "md5:63645f6fb99a9d811299b8821d6b4b87"
    # iso_target_path     = "iso/SLE-15-SP5-Full-x86_64-GM-Media1.iso"
    # cd_files            = ["/home/gigi/Téléchargements/SLE-15-SP5-Full-x86_64-GM-Media1.iso"]
    # cd_label            = "cidata"
    http_content        = local.data_source_content
    # http_directory      = "http"
    # cd_content          = var.common_data_source == "disk" ? local.data_source_content : null
    output_directory    = "build"
    # qemu_binary         = "/usr/bin/kvm" # /usr/bin/qemu-system-x86_64
    shutdown_command    = "sudo /usr/bin/systemctl shutdown"
    disk_size           = "45G"
    # disk_discard        = "unmap"
    # disk_cache          = null
    # disk_compression    = true
    format              = "qcow2"
    accelerator         = "kvm"
    ssh_wait_timeout    = "60m"
    ssh_username        = "root"
    ssh_password        = "changeme!"
    ssh_pty             = true
    ssh_timeout         = "20m"
    vm_name             = "sles15sp5.qcow2"
    net_device          = "virtio-net"
    disk_interface      = "virtio"
    boot_wait           = "5s"
    # https://developer.hashicorp.com/packer/integrations/hashicorp/qemu/latest/components/builder/qemu#boot-configuration
    boot_command        = [
      # "<f2><down><down><down><enter>",
      "<down>biosdevname=0 netsetup=dhcp autoyast=http://{{ .HTTPIP }}:{{ .HTTPPort }}/autoinst.xml<enter>",
      # "biosdevname=0 ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/xml<enter>"
    ]
    qemuargs            = [
      [
        "-display",
        "gtk"
      ],
      [
        "-machine",
        "accel=kvm"
      ],
      [
        "-m",
        "2048M"
      ],
      [
        "-smp",
        "2"
      ]
    ]
}

build {
  sources = ["source.qemu.sles15-sp5"]
}