
output "demo" {
  value = null_resource.demo[*].id
}

output "hosts" {
  value = null_resource.hosts[*]
}
