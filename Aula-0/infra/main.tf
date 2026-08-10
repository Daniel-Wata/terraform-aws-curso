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
  region = "us-east-1"
  profile = "watadados"
}

resource "aws_s3_bucket" "state-bucket" {
  bucket = "django-state-bucket-watadados"

  tags = {
    Name        = "State bucket"
    Environment = "Prod"
  }

  force_destroy = true
}