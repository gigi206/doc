# Packer
* [Doc](https://developer.hashicorp.com/packer)
* [Download](https://developer.hashicorp.com/packer/install)
* Examples for multiples OS:
  * https://github.com/vmware-samples/packer-examples-for-vsphere/tree/develop/builds/linux (cf [documentation](https://vmware-samples.github.io/packer-examples-for-vsphere/))
  * https://github.com/mrlesmithjr/packer-templates/

## Tuto
* [Getting Started with Docker](https://developer.hashicorp.com/packer/tutorials/docker-get-started)
* [Getting Started with AWS](https://developer.hashicorp.com/packer/tutorials/aws-get-started)

## Cli
* https://developer.hashicorp.com/packer/docs/commands

## Functions
* https://developer.hashicorp.com/packer/docs/templates/hcl_templates/functions

### Try
* [can](https://developer.hashicorp.com/packer/docs/templates/hcl_templates/functions/conversion/can)
* [try](https://developer.hashicorp.com/packer/docs/templates/hcl_templates/functions/conversion/try)

```js
locals {
  raw_value = yamldecode("${path.folder}/example.yaml")
  normalized_value = {
    name   = tostring(try(local.raw_value.name, null))
    groups = try(local.raw_value.groups, [])
  }
}
```

```js
variable "example" {
  type = any
}

locals {
  example = try(
    [tostring(var.example)],
    tolist(var.example),
  )
}
```

# Integration
* https://developer.hashicorp.com/packer/integrations
  * [Ansible](https://developer.hashicorp.com/packer/integrations/hashicorp/ansible)
  * [Docker](https://developer.hashicorp.com/packer/integrations/hashicorp/docker)
  * [VMware](https://developer.hashicorp.com/packer/integrations/hashicorp/vmware)
  * [VMware vSphere](https://developer.hashicorp.com/packer/integrations/hashicorp/vsphere)
  * [VirtualBox](https://developer.hashicorp.com/packer/integrations/hashicorp/virtualbox)
  * [QEMU](https://developer.hashicorp.com/packer/integrations/hashicorp/qemu)
  * [Vagrant](https://developer.hashicorp.com/packer/integrations/hashicorp/vagrant)
  * [Git](https://developer.hashicorp.com/packer/plugins/datasources/git)
  * [Libvirt](https://developer.hashicorp.com/packer/plugins/builders/libvirt)

## Syntax
* https://developer.hashicorp.com/packer/docs/templates/hcl_templates/syntax
* [Expressions](https://developer.hashicorp.com/packer/docs/templates/hcl_templates/expressions)

## References
* [only/except](https://developer.hashicorp.com/packer/docs/templates/hcl_templates/onlyexcept)

* [locals](https://developer.hashicorp.com/packer/docs/templates/hcl_templates/locals)
* [variables](https://developer.hashicorp.com/packer/docs/templates/hcl_templates/variables)
* [Contextual variables](https://developer.hashicorp.com/packer/docs/templates/hcl_templates/contextual-variables)
* [path-variables](https://developer.hashicorp.com/packer/docs/templates/hcl_templates/path-variables)
* [data](https://developer.hashicorp.com/packer/docs/templates/hcl_templates/datasources)
* [block](https://developer.hashicorp.com/packer/docs/templates/hcl_templates/blocks)
  * [locals](https://developer.hashicorp.com/packer/docs/templates/hcl_templates/blocks/locals)
  * [variable](https://developer.hashicorp.com/packer/docs/templates/hcl_templates/blocks/variable)
  * [source](https://developer.hashicorp.com/packer/docs/templates/hcl_templates/blocks/source)
  * [packer](https://developer.hashicorp.com/packer/docs/templates/hcl_templates/blocks/packer)
  * [data](https://developer.hashicorp.com/packer/docs/templates/hcl_templates/blocks/data)
  * [build](https://developer.hashicorp.com/packer/docs/templates/hcl_templates/blocks/build)
    * [source](https://developer.hashicorp.com/packer/docs/templates/hcl_templates/blocks/build/source)
    * [provisionner](https://developer.hashicorp.com/packer/docs/templates/hcl_templates/blocks/build/provisioner)
    * [post-processor](https://developer.hashicorp.com/packer/docs/templates/hcl_templates/blocks/build/post-processor)
    * [post-processors](https://developer.hashicorp.com/packer/docs/templates/hcl_templates/blocks/build/post-processors)

# packer
Example:
```js
packer {
  required_version = ">= 1.7.0"
  required_plugins {
    vmware = {
      version = ">= 1.0.0"
      source = "github.com/hashicorp/vmware"
    }
  }
}
```
