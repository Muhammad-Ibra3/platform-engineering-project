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
  region = var.aws_region
}