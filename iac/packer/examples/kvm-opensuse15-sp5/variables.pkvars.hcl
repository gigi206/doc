##################################################################################
# VARIABLES
##################################################################################


data_source                 = "disk"

# HTTP Settings
http_directory              = "http"

# Boot
boot_command_custom         = ""
vm_boot_wait                = "1s"

# Virtual Machine Settings
vm_name                     = "OpenSUSE-15.5"
vm_cpu                      = 2
vm_mem_size                 = 2048
vm_disk_size                = "20G"
cd_label                    = "cidata"
ssh_username                = "packer"
ssh_password                = "packer"

# ISO Objects
iso_url                     = "http://mirror.us.leaseweb.net/opensuse/distribution/leap/15.5/iso/openSUSE-Leap-15.5-NET-x86_64-Current.iso"
iso_url_checksum            = "http://mirror.us.leaseweb.net/opensuse/distribution/leap/15.5/iso/openSUSE-Leap-15.5-NET-x86_64-Current.iso.sha256"
iso_checksum                = null
// iso_checksum                = "file:https://xxx/SHA256SUMS"
iso_checksum_type           = "sha256"
