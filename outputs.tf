output "generic_public_ip" {
  value = aws_instance.app_server.public_ip
}

output "instance_id" {
  value = aws_instance.app_server.id
}

output "arn" {
  value = aws_instance.app_server.arn
}