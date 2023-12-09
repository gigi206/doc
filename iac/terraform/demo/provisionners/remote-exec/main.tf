# https://developer.hashicorp.com/terraform/language/resources/provisioners/remote-exec
resource "null_resource" "demo" {
  # Establishes connection to be used by all
  # generic remote provisioners (i.e. file/remote-exec)
  connection {
    type     = "ssh"
    host     = var.ssh_host
    user     = var.ssh_user
    # password = var.root_password
    # private_key = file("/home/gigi/.ssh/id_rsa")
  }

  provisioner "remote-exec" {
    inline = [
      "id",
      "hostnamectl",
    ]
  }
}
