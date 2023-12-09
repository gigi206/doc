# SLES 15 SP5
## Download plugins
```shell
$ packer init kvm-sles15-sp5.pkr.hcl
Installed plugin github.com/hashicorp/qemu v1.0.10 in "/home/gigi/.config/packer/plugins/github.com/hashicorp/qemu/packer-plugin-qemu_v1.0.10_x5.0_linux_amd64
```

## Build
```shell
$ packer build kvm-sles15-sp5.pkr.hcl
```