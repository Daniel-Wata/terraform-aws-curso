terraform {
    required_version = ">= 1.10"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.region
  profile = var.profile

  default_tags {
    tags = {
      Project = var.project_name
      Environment = var.environment
      ManagedBy = "terraform" 
    }
  }
}

