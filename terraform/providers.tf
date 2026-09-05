terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
  backend "s3" {
    bucket         = "internship-tracker-tfstate-akram"
    key            = "global/terraform.tfstate"
    region         = "eu-west-3"
    use_lockfile   = true
  }
}

provider "aws" {
  region = "eu-west-3"
}
