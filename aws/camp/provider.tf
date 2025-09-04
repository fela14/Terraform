terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  shared_credentials_files = ["~/Terraform/aws/camp/credentials"]
  profile                  = "customprofile"
  region                   = "us-east-1"
}
