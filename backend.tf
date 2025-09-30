terraform {
  backend "s3" {
    bucket = "test-bucket"
    region = "us-east-1"
    key = "github/terraform.tfstate"
    encrypt = true
  }
  required_version = ">=0.13.0"
  required_providers {
    aws = {
      version = ">=2.7.0"
      source = "hashicorp/aws"
    }
  }
}