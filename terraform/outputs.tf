output "ec2_public_ip" {
  value = aws_instance.app_server.public_ip
}
output "ec2_key_pair_name" {
  value = aws_instance.app_server.key_name
}