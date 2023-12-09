# Ubuntu 22.04
* Source: https://gitlab.com/public-projects3/infrastructure-vmware-public/vmware-packer-ubuntu22.04-public
* Youtube: https://www.youtube.com/watch?v=FvQuVWk2f6s

```shell
packer build -force -on-error=ask -var-file variables.pkrvars100GBdisk.hcl -var-file vsphere.pkrvars.hcl ubuntu-22.04.pkr.hcl
```
