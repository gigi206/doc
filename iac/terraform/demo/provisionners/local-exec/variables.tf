variable "demo" {
  # type = list(string)
  default = [
    "This is a demo1!",
    "This is a demo2!",
    "This is a demo3!",
  ]
}

variable "hosts" {
  default = {
    "localhost" = "127.0.0.1"
    "host1"     = "192.168.0.1"
    "host2"     = "192.168.0.1"
  }
}