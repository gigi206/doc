resource "null_resource" "file" {
  # Copies the myapp.conf file to /etc/myapp.conf
#   provisioner "file" {
#     source      = "conf/myapp.conf"
#     destination = "/etc/myapp.conf"
#   }

  connection {
    type     = "ssh"
    host     = "localhost"
    user     = "gigi"
    # password = "${var.root_password}"
  }

  # Copies the string in content into /tmp/file.log
  provisioner "file" {
    content     = "This is a demo"
    destination = "/tmp/file.log"
  }
}