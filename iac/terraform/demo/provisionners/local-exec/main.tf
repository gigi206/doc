# https://developer.hashicorp.com/terraform/language/resources/provisioners/local-exec

resource "null_resource" "demo" {
  count = length(var.demo)
  provisioner "local-exec" {
    command = "echo ${element(var.demo, count.index)}"
    when = destroy
  }
}

resource "null_resource" "hosts" {
  for_each = var.hosts
  triggers = {
    foo = each.value
  }
  provisioner "local-exec" {
    command = "echo ${each.key} ${each.value}"
    when = create
  }
}
