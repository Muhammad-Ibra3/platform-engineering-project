output "k3s_public_ip" {
  description = "The public IP of the active k3s node."
  value       = aws_instance.k3s_node.public_ip
}

output "k3s_public_dns" {
  description = "The public DNS name of the active k3s node."
  value       = aws_instance.k3s_node.public_dns
}

output "k3s_node_role_arn" {
  description = "IAM role ARN attached to the k3s EC2 node."
  value       = aws_iam_role.k3s_node.arn
}

output "k3s_node_instance_profile_name" {
  description = "IAM instance profile attached to the k3s EC2 node."
  value       = aws_iam_instance_profile.k3s_node.name
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

output "kubecost_federated_storage_bucket_name" {
  description = "S3 bucket name for Kubecost federated storage."
  value       = aws_s3_bucket.kubecost_federated_storage.bucket
}

output "platform_hosted_zone_id" {
  description = "Route53 hosted zone ID for the platform domain."
  value       = aws_route53_zone.platform_public.zone_id
}

output "platform_hosted_zone_name_servers" {
  description = "Authoritative Route53 name servers for the platform domain."
  value       = aws_route53_zone.platform_public.name_servers
}