# https://registry.terraform.io/providers/hashicorp/local/latest/docs
terraform {
  required_providers {
    local = {
      source = "hashicorp/local"
      version = "2.4.0"
    }
  }
}

provider "local" {
  # Configuration options
}

resource "local_file" "foo" {
  content  = "foo!"
  filename = "${path.module}/foo.bar"
}

resource "local_sensitive_file" "bar" {
  content  = "bar!"
  filename = "${path.module}/bar.bar"
}