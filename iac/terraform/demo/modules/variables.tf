variable "ssh_host" {
  type        = string
  description = "ssh host to connect to"
  default     = "localhost"
}

variable "ssh_user" {
  type        = string
  description = "ssh user"
  default     = "root"
}
