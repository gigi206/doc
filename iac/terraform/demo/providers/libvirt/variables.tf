variable "virtual_machine" {
  # type    = map
  # default = {}
  type        = object({
      name    = string
      ip      = string
      cpu     = number
      memory  = number
      dhcp    = bool
    }
  )
  description = "Description of the virtual machine to deploy"
}

variable "dhcp" {
  type        = bool
  description = "Configure the VM with a static IP or with a provisionned IP"
  default     = true
}
