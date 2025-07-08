output "mysql_instance_public_ip" {
  value = module.mysql_server.public_ip
}

output "mysql_instance_id" {
  value = module.mysql_server.id
}
