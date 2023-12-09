variable "name" {
    type = string
    description = "Name of the virtual machine"
}

variable "ip" {
    type = string
    description = "IP of the virtual machine"
}

variable "cpu" {
    type = number
    description = "Number of CPUs"
    default = 2
}

variable "memory" {
    type = number
    description = "Amount of memory"
    default = 1024
}

variable "dhcp" {
  type        = string
  description = "Configure the VM with a static IP or with a provisionned IP"
  default     = true
}

variable "libvirt_network_name" {
    type = string
    description = "The name of the network"
    default = "default"
}