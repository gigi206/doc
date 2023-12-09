# https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
  }
}

provider "docker" {
  host = "unix:///run/user/1000/podman/podman.sock"
}

data "docker_registry_image" "nginx" {
  name = "nginx:latest"
}

resource "docker_image" "nginx" {
  name          = data.docker_registry_image.nginx.name
  pull_triggers = [data.docker_registry_image.nginx.sha256_digest]
  keep_locally  = false
}

resource "docker_container" "nginx" {
  image = docker_image.nginx.name
  # image = docker_image.nginx.latest
  name  = "nginx"
  ports {
    internal = 80
    external = 8080
  }
  depends_on = [ docker_image.nginx ]
}