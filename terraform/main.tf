terraform {
  # NOTE : Shared remote backend such as consul can be used to maintain the statefile if multiple administrators are managing the infra via terraform
  # since this is an one off setup i will use local state files 
  # backend "consul" {
  #   address = "consul.example.com"
  #   scheme  = "https"
  # ## consult access token can be provided via envionment variables or partial configuration
  #   path    = "full/path"
  # }
  # you can also use worspaces to create replicas of the environment for prod, dev and staging, It is not used here t keep things simple

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region                  = var.region
  profile                 = var.aws_profile
  default_tags {
    tags = var.default_tags
  }
}

data "aws_caller_identity" "current" {}