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

resource "aws_s3_bucket" "state-bucket" {
  bucket = var.state_bucket_name

  tags = {
    Name        = "State bucket"
    Environment = "Prod"
  }

  force_destroy = true
}

variable "profile" {
  type = string
  description = "Perfil utilizado pelo usuario para login na AWS"
  default = null
}

variable "region" {
  type = string
  description = "Regiao da AWS"
  default = null
}

variable "state_bucket_name" {
  type = string
  description = "nome do bucket de estado"
  default = null
}