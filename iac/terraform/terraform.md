# Terraform
## Download
* https://developer.hashicorp.com/tutorials/library?product=terraform

## Tutorial
* [Tutorial Library](https://developer.hashicorp.com/tutorials/library?product=terraform)
* [Xavki](https://www.youtube.com/playlist?list=PLn6POgpklwWrpWnv05paAdqbFbV6gApHx)

## Documentation
* [Official](https://developer.hashicorp.com/terraform/docs)

## Backend
Terraform support multiple backend to store the `tfstate` file like `s3` for example:
* [s3 backend](https://developer.hashicorp.com/terraform/language/settings/backends/s3)

## variables
* [Tuto Xavki Youtube](https://youtu.be/4l_y3D58_iE?list=PLn6POgpklwWrpWnv05paAdqbFbV6gApHx)

### Prompt
```hcl
variable "myvar" {}
```

### Environment
```shell
export TF_VAR_myvar="env"
```

### Fichiers
* `terraform.tfvars`:
```shell
myvar="env"
```

* `*auto.tfvars` ou `*auto.tfvars.json`:
```shell
myvar="env"
```

### command line
```shell
terraform apply -var myvar="env"
terraform apply -var-file myenvfile
```

## Command line
### workspace
**INFO:** see also [Terragrunt](https://terragrunt.gruntwork.io/) for that: [Terragrunt VS Terraform](https://spacelift.io/blog/terragrunt-vs-terraform)

![](https://spacelift.io/_next/image?url=https%3A%2F%2Fspaceliftio.wpcomstaging.com%2Fwp-content%2Fuploads%2F2023%2F06%2Fterraform-vs-terragrunt.png&w=1920&q=75)

![](https://user-images.githubusercontent.com/711908/185466543-990a08d7-165d-42e3-83a1-70b604cdee06.png)

* Use the variable `terraform.workspace` to point on the current workspace:
```hcl
locals {
  env = "${terraform.workspace}"
}
```

* List all workspaces:
```
terraform workspace list
```

* Current workspace:
```
terraform workspace show
```

* Create a new one:
```
terraform workspace create prod
```

* Switch to another workspace:
```
terraform workspace select dev
```

## Examples
### workspace
* [Youtube Xavki](https://www.youtube.com/watch?v=WcazKyt2n_U&list=PLn6POgpklwWrpWnv05paAdqbFbV6gApHx&index=34):
* Workspace is just the `terraform.workspace` that contains the value for the current workspace. Below an example:
```hcl
provider "libvirt" {
  uri = "qemu:///system"
}

locals {
  env="${terraform.workspace}"
  net = {
    dev = "10.0.2"
    prod = "10.0.1"
  }
  instance1 = {
      ip = "${lookup(local.net,local.env)}.2"
      name = "instance1"
  }
  instance2 = {
      ip = "${lookup(local.net,local.env)}.2"
      name = "instance2"
  }
}

resource "libvirt_pool" "pool_mycentos" {
  name = "mycentos_${terraform.workspace}"
  type = "dir"
  path = "/disklv/images/${terraform.workspace}"
}


resource "libvirt_network" "vm_network" {
  name = "vm_network_${terraform.workspace}"
  addresses = ["${lookup(local.net,local.env)}.0/24"]
  mode = "nat"
  dhcp {
   enabled = false
  }
}

module "instance1" {
  source    = "./modules/instances"
  ip        = local.instance1.ip
  network   = libvirt_network.vm_network.name
  name      = "${local.instance1.name}-${local.env}"
  pool      = libvirt_pool.pool_mycentos.name
}
module "instance2" {
  source    = "./modules/instances"
  ip        = local.instance2.ip
  network   = libvirt_network.vm_network.name
  name      = "${local.instance2.name}-${local.env}"
  pool      = libvirt_pool.pool_mycentos.name
}
```

### lookup
* Get a default variable if empty:
```hcl
locals {
  net = {
    default = "192.168.100.0"
  }
}

output "network" {
    value = lookup(local.net, "network1", local.net.default)
}
```

### locals
`locals` can be useful to compute dynamically variables that can be used multiple times in the code:
```hcl
locals {
  # Ids for multiple sets of EC2 instances, merged together
  instance_ids = concat(aws_instance.blue.*.id, aws_instance.green.*.id)
}
```

### external datasource
* External datasource can be used to simulate a function:
```hcl
variable "address" {
  default = "192.168.1.1"
}

variable "cidr" {
  default = "192.168.1.0/24"
}

data "external" "example1" {
  program = ["python3", "-c", "import ipaddress, json; print(json.dumps({'key': str(ipaddress.IPv4Address('${var.address}') in ipaddress.IPv4Network('${var.cidr}'))}));"]
}

output "example1" {
  value = tobool(lower(data.external.example1.result.key))
}
```

### Error management
#### variable control
* Check if the input is correct:
```hcl
variable "myvar" {
    default = "192.168.0.0"
    type = string
    description = "(optional) describe your variable"
    validation {
      condition     = can(cidrnetmask("${var.myvar}/32"))
      error_message = "Must be a valid IPv4 CIDR block address."
    }
}
```

#### Warnings
* Check the code before approving:
```
check "check_network1" {
  assert {
    condition = lookup(local.net, "network1", false)
    error_message = "Failed !!!!!!!!!!!!!!!!!!"
  }
}
```

#### Generate a warning or error depending condition
* [Provider validation](https://registry.terraform.io/providers/tlkamp/validation/latest/docs/resources/error)
* Below an example with warning (continue) and error (exit):
```hcl
terraform {
  required_providers {
    validation = {
      source = "tlkamp/validation"
      version = "1.0.0"
    }
  }
}

provider "validation" {
  # Configuration options
}

variable "one" {}
variable "two" {}

resource "validation_error" "error" {
  condition = var.one == var.two
  summary = "var.one and var.two must never be equal"
  details = <<EOF
When var.one and var.two are equal, bad things can happen.
Please use differing values for these inputs.
var.one: ${var.one}
var.two: ${var.two}
EOF
}

resource "validation_warning" "warn" {
  condition = var.one == var.two
  summary = "var.one and var.two are equal. This will cause an error in future versions"
  details = <<EOF
In a future release of this code, var.one and var.two may no longer be equal. Please consider modifying the values to
be distinct to avoid execution failures.
var.one: ${var.one}
var.two: ${var.two}
EOF
}
```