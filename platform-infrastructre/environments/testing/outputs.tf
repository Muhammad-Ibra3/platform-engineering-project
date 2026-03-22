output "k3s_public_ip" {
  description = "The public IP of the active k3s node."
  value       = aws_instance.k3s_node.public_ip
}

output "k3s_public_dns" {
  description = "The public DNS name of the active k3s node."
  value       = aws_instance.k3s_node.public_dns
}