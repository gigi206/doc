# OpenSUSE
## Packer

```shell
GTK_PATH= /home/gigi/packer/packer build -var-file=variables.pkvars.hcl kvm-opensuse-leap-15-sp5.pkr.hcl
```

```shell
GTK_PATH= PACKER_LOG=1 /home/gigi/packer/packer build -var-file=variables.pkvars.hcl kvm-opensuse-leap-15-sp5.pkr.hcl
```

## Autoyast
* https://doc.opensuse.org/documentation/leap/autoyast/single-html/book-autoyast/index.html
* https://documentation.suse.com/sles/15-SP5/html/SLES-all/cha-autoyast-create-control-file.html

### Generate custom autoyast
* Verify that both autoyast2-installation and autoyast2 are installed
```shell
zypper in -y autoyast2-installation autoyast2
```

* Generate a custom autoyast:
```shell
/sbin/yast2 autoyast
```

### Generate autoyast
* Clone your current system:
```shell
yast2 clone_system
```
