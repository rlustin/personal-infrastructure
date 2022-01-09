terraform {
  backend "s3" {
    bucket  = "rlustin-tfstate-storage"
    key     = "aws-terraform.tfstate"
    profile = "personal"
    region  = "eu-west-3"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.46.0"
    }
  }

  required_version = ">= 0.13"
}

provider "aws" {
  alias   = "euwest"
  profile = "personal"
  region  = "eu-west-3"
}

module "global_vars" {
  source = "../global_vars"
}
