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
}

resource "aws_s3_bucket" "first" {
    bucket = "${local.name_prefix}-first"
    force_destroy = true
}

