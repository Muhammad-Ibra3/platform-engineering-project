terraform {
  backend "s3" {
    bucket = "platform-infra-terraform-state-016257615702-us-east-1-an"
    key    = "k3s/terraform.tfstate"
    region = "us-east-1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# 1. Security Group for Direct EC2 Access
resource "aws_security_group" "k3s_testing_sg" {
  name        = "k3s-testing-sg"
  description = "Allow inbound traffic for k3s, Traefik, and SSH"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.k3s_allowed_ip] 
  }

  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = [var.k3s_allowed_ip] # Comment out before pushing to main
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Comment out before pushing to main
  }
}

# 2. ACTIVE: Free Tier On-Demand Instance
resource "aws_instance" "k3s_node_free_tier" {
  ami           = "ami-0b6c6ebed2801a5cb" # Ubuntu 24.04 LTS 
  instance_type = "m7i-flex.large" # Free tier eligible
  
  vpc_security_group_ids = [aws_security_group.k3s_testing_sg.id]
  key_name               = "k3s testing key"

  root_block_device {
    volume_size = 10
    volume_type = "gp3"
  }

  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              
              apt-get install -y docker.io
              systemctl enable docker
              systemctl start docker
              usermod -aG docker ubuntu

              TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
              PUBLIC_IP=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/public-ipv4)

              curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

              k3d cluster create gitops-portfolio \
                --api-port 6443 \
                -p "80:80@loadbalancer" \
                -p "443:443@loadbalancer" \
                --k3s-arg "--tls-san=$PUBLIC_IP@server:0"

              k3d kubeconfig get gitops-portfolio > /home/ubuntu/kubeconfig.yaml
              sed -i "s/0.0.0.0/$PUBLIC_IP/g" /home/ubuntu/kubeconfig.yaml
              
              chown ubuntu:ubuntu /home/ubuntu/kubeconfig.yaml
              chmod 600 /home/ubuntu/kubeconfig.yaml

              curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
              install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
              rm kubectl

              curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

              export KUBECONFIG=/home/ubuntu/kubeconfig.yaml
              kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
              kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
              kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd
              kubectl wait --for=condition=available --timeout=300s deployment/argocd-applicationset-controller -n argocd
              kubectl apply -f https://raw.githubusercontent.com/Muhammad-Ibra3/platform-engineering-project/main/platform-gitops/argo/argo-init-dev.yaml

              echo 'export KUBECONFIG=/home/ubuntu/kubeconfig.yaml' >> /home/ubuntu/.bashrc
              echo "alias k='kubectl'" >> /home/ubuntu/.bashrc
              
              echo 'alias kn="kubectl config set-context --current --namespace"' >> /home/ubuntu/.bashrc
              echo 'alias kx="kubectl config use-context"' >> /home/ubuntu/.bashrc
              EOF

  tags = {
    Name = "k3s-gitops-node-freetier"
  }
}

# =====================================================================
# 3. Ephemeral Spot Instance (For Milestone 2+ Scaling)
# =====================================================================
# resource "aws_spot_instance_request" "k3s_node_spot" {
#   ami           = "ami-0b6c6ebed2801a5cb"
#   instance_type = "t3.xlarge"
#   spot_price    = "0.07" 
#   wait_for_fulfillment = true
#   spot_type            = "one-time"
#
#   vpc_security_group_ids = [aws_security_group.k3s_testing_sg.id]
#   # key_name can be set to an existing EC2 key pair if desired
#
#   user_data = <<-EOF
#               #!/bin/bash
#               apt-get update -y
#               curl -sfL https://get.k3s.io | sh -
#               chmod 644 /etc/rancher/k3s/k3s.yaml
#               export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
#               echo "export KUBECONFIG=/etc/rancher/k3s/k3s.yaml" >> /home/ubuntu/.bashrc
#               EOF
#
#   tags = {
#     Name = "k3s-gitops-node-spot"
#   }
# }

# 4. Output the IP
output "k3s_public_ip" {
  description = "The public IP of the active k3s node."
  value       = aws_instance.k3s_node_free_tier.public_ip
}