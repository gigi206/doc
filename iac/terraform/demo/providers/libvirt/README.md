# libvirt provider
# issues
* To fix the `Permission denied` issue:
```shell
libvirt_domain.debian12: Creating...
╷
│ Error: error creating libvirt domain: internal error: process exited while connecting to monitor: 2023-12-10T13:56:43.372914Z qemu-system-x86_64: -blockdev {"driver":"file","filename":"/home/kvm/vms/debian12.qcow2","node-name":"libvirt-1-storage","auto-read-only":true,"discard":"unmap"}: Could not open '/home/kvm/vms/debian12.qcow2': Permission denied
│
│   with libvirt_domain.debian12,
│   on main.tf line 21, in resource "libvirt_domain" "debian12":
│   21: resource "libvirt_domain" "debian12" {
```

* Edit `/etc/libvirt/qemu.conf` file and set the `security_driver` to `none`:
```shell
security_driver = "none"
```

* Restart libvirt:
```shell
sudo systemctl restart libvirtd.service
```
