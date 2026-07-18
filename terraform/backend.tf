terraform {
  backend "s3" {
    bucket         = "fintech-payflow-tfstate"
    key            = "payflow/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    kms_key_id     = "alias/payflow-s3-key"
    dynamodb_table = "payflow-tfstate-lock"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.50"
    }
  }
  required_version = ">= 1.9.0"
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Project   = "payflow-pro"
      ManagedBy = "terraform"
      Team      = "platform-engineering"
      PCIScope  = "true"
      Env       = terraform.workspace
      Repo      = "hrushiph-aigarden/payflow-infra"
    }
  }
}

variable "aws_region" {
  default = "us-east-1"
}
