variable "aws_region" {
  description = "AWS region to deploy the instance into."
  type        = string
  default     = "us-east-1"
}

variable "k3s_allowed_ip" {
  description = "CIDR block allowed to access SSH and the Kubernetes API."
  type        = string
}

variable "instance_ami" {
  description = "Ubuntu AMI for the EC2 instance."
  type        = string
  default     = "ami-0b6c6ebed2801a5cb"
}

variable "instance_type" {
  description = "EC2 instance type for the k3s node."
  type        = string
  default     = "m7i-flex.xlarge"
}

variable "key_name" {
  description = "Existing AWS EC2 key pair name."
  type        = string
  default     = "k3s testing key"
}

variable "root_volume_size" {
  description = "Root EBS volume size in GiB."
  type        = number
  default     = 20
}

variable "instance_name" {
  description = "Tag name for the EC2 instance."
  type        = string
  default     = "k3s-gitops-node"
}

variable "security_group_name" {
  description = "Name of the EC2 security group."
  type        = string
  default     = "k3s-testing-sg"
}

variable "k3s_version" {
  description = "Pinned k3s version to install."
  type        = string
  default     = "v1.32.3+k3s1"
}

variable "k3s_node_role_name" {
  description = "IAM role name attached to the k3s EC2 node."
  type        = string
  default     = "k3s-node-ecr-pull-only"
}

variable "k3s_node_instance_profile_name" {
  description = "IAM instance profile name attached to the k3s EC2 node."
  type        = string
  default     = "k3s-node-ecr-pull-only-testing"
}

variable "github_actions_role_name" {
  description = "IAM role name assumed by GitHub Actions for ECR access."
  type        = string
  default     = "github-actions-ecr-testing"
}

variable "github_oidc_repositories" {
  description = "List of GitHub repositories allowed to assume the GitHub Actions IAM role (org/repo format)."
  type        = list(string)
  default = [
    "Muhammad-Ibra3/platform-engineering-project",
    "Muhammad-Ibra3/microservices-apps-project",
  ]
}

variable "ecr_credential_provider_version" {
  description = "Pinned upstream cloud-provider-aws ecr-credential-provider version. Keep this on the same Kubernetes minor as k3s."
  type        = string
  default     = "v1.32.7"
}

variable "kubecost_federated_storage_bucket_name" {
  description = "S3 bucket name used by Kubecost federated storage."
  type        = string
  default     = "dev-kubecost-federated-store"
}