output "k3s_public_ip" {
  description = "The public IP of the active k3s node."
  value       = aws_instance.k3s_node.public_ip
}

output "k3s_public_dns" {
  description = "The public DNS name of the active k3s node."
  value       = aws_instance.k3s_node.public_dns
}

output "microservice_ecr_repository_urls" {
  description = "Map of microservice name to ECR repository URL."
  value       = { for name, repo in aws_ecr_repository.microservices : name => repo.repository_url }
}

output "github_actions_role_arn" {
  description = "IAM role ARN for GitHub Actions to assume for ECR push/pull."
  value       = aws_iam_role.github_actions_ecr.arn
}

output "github_actions_oidc_provider_arn" {
  description = "OIDC provider ARN for GitHub Actions federation."
  value       = aws_iam_openid_connect_provider.github_actions.arn
}