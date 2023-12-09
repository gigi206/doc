module "test" {
    source   = "../provisionners/remote-exec"
    ssh_host = var.ssh_host
    ssh_user = var.ssh_user
}