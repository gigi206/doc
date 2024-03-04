# Foreman
## Tuto
* https://devopstales.github.io/linux/foreman-pxe/
* https://devopstales.github.io/sso/foreman-sso/

## Forement installation
* [Quickstart](https://theforeman.org/manuals/3.9/quickstart_guide.html)

```shell
foreman-installer \
    # --foreman-initial-organization=XXX \
    # --foreman-initial-location=office \
    # --foreman-initial-admin-password=xxxx \
    --foreman-proxy-dhcp=true \
    --foreman-proxy-dhcp-interface=enp1s0 \
    --foreman-proxy-dhcp-gateway=192.168.100.1 \
    --foreman-proxy-dhcp-nameservers=192.168.100.1 \
    --foreman-proxy-tftp=true \
    --foreman-proxy-tftp-servername=true \
    --enable-foreman-plugin-ansible \
    --enable-foreman-proxy-plugin-ansible \
    --enable-foreman-plugin-remote-execution \
    --enable-foreman-proxy-plugin-remote-execution-ssh \
    --enable-foreman-plugin-cockpit \
    --enable-foreman-plugin-openscap \
    # --foreman-proxy-plugin-openscap-ansible-module
```

## Hammer
### Hammer config
Edit `~/.hammer/cli.modules.d/foreman.yml`
```
:foreman:
 :host: 'https://foreman.devopstales.intra/'
 :username: 'admin'
 :password: '**********'
```

hammer defaults add --param-name organization --param-value "mydomain"
hammer defaults add --param-name location --param-value "office"
hammer defaults list

### Hammer cli
#### subnet
```shell
hammer subnet create \
    --name PXEnet \
    --network-type IPv4 \
    --network 192.168.100.0 \
    --mask 255.255.255.0 \
    --dns-primary 192.168.100.100 \
    --domains devopstales.intra \
    --tftp-id 1 \
    --httpboot-id 1 \
    --ipam "Internal DB" \
    --from 192.168.100.101 \
    --to 192.168.100.200 \
    --boot-mode Static
```

#### medium
```shell
hammer medium create \
    --name "CentOS7_DVD_FTP" \
    --os-family "Redhat" \
    --path "ftp://foreman.devopstales.intra/pub/CentOS_7_x86_64/"
```

#### partition_table
File `hardened_ptable`:
```
<%#
kind: ptable
name: Kickstart hardened
oses:
- CentOS
- Fedora
- RedHat
%>

# System bootloader configuration
bootloader --location=mbr --boot-drive=sda --timeout=3
# Partition clearing information
clearpart --all --drives=sda
zerombr

# Disk partitioning information
part /boot --fstype="xfs" --ondisk=sda --size=1024 --label=boot --fsoptions="rw,nodev,noexec,nosuid"

# 30GB physical volume
part pv.01  --fstype="lvmpv" --ondisk=sda --size=30720
volgroup vg_os pv.01

logvol /        --fstype="xfs"  --size=4096 --vgname=vg_os --name=lv_root
logvol /home    --fstype="xfs"  --size=512  --vgname=vg_os --name=lv_home --fsoptions="rw,nodev,nosuid"
logvol /tmp     --fstype="xfs"  --size=1024 --vgname=vg_os --name=lv_tmp  --fsoptions="rw,nodev,noexec,nosuid"
logvol /var     --fstype="xfs"  --size=6144 --vgname=vg_os --name=lv_var  --fsoptions="rw,nosuid"
logvol /var/log --fstype="xfs"  --size=512  --vgname=vg_os --name=lv_log  --fsoptions="rw,nodev,noexec,nosuid"
logvol swap     --fstype="swap" --size=2048 --vgname=vg_os --name=lv_swap --fsoptions="swap"
```

```shell
hammer partition-table create \
  --name "Kickstart hardened" \
  --os-family "Redhat" \
  --operatingsystems "CentOS 7.4.1708" \
  --file "hardened_ptable.txt"
```

#### os
```shell
hammer os create \
  --name "CentOS" \
  --major "7" \
  --minor "4.1708" \
  --family "Redhat" \
  --password-hash "SHA512" \
  --architectures "x86_64" \
  --media "CentOS7_DVD_FTP" \
  --partition-tables "Kickstart hardened"
```

#### hostgroup
```shell
hammer hostgroup create \
  --name "el7_group" \
  --description "Host group for CentOS 7 servers" \
  --lifecycle-environment "stable" \
  --content-view "el7_content" \
  --content-source-id "1" \
  --environment "homelab" \
  --puppet-proxy "foreman.devopstales.intra" \
  --puppet-ca-proxy "foreman.devopstales.intra" \
  --domain "devopstales.intra" \
  --subnet "PXEnet" \
  --architecture "x86_64" \
  --operatingsystem "CentOS 4.1708" \
  --medium "CentOS7_DVD_FTP" \
  --partition-table "Kickstart hardened" \
  --pxe-loader "PXELinux BIOS" \
  --root-pass "Password1"
```

```shell
hammer hostgroup set-parameter  \
  --name "selinux-mode" \
  --value "disabled" \
  --hostgroup "el7_group"
```

```shell
hammer hostgroup set-parameter  \
  --name "disable-firewall" \
  --value "true" \
  --hostgroup "el7_group"
```

```shell
hammer hostgroup set-parameter  \
  --name "bootloader-append" \
  --value "net.ifnames=0 biosdevname=0" \
  --hostgroup "el7_group"
```

#### host
```shell
hammer host create \
  --name "pxe-test" \
  --hostgroup "el7_group" \
  --interface "type=interface,mac=08:00:27:fb:ad:17,ip=192.168.100.110,managed=true,primary=true,provision=true"
```

## Katello Installation
* https://devopstales.github.io/linux/katello-install/