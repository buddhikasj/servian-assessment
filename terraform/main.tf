terraform {
  # NOTE : Shared remote backends such as consul can be used to maintain the statefile if multiple administrators are managing the infra via terraform
  # since this is an one off setup i will use local state files 
  # backend "consul" {
  #   address = "consul.example.com"
  #   scheme  = "https"
  # ## consult access token can be provided via envionment variables or partial configuration
  #   path    = "full/path"
  # }
  # you can also use worspaces to create replicas of the environment for prod, dev and staging, It is not used here to keep things simple

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

#### Create AWS Provider with the region the application will be deployed in and local profile being used for access
provider "aws" {
  region                  = var.region
  profile                 = var.aws_profile
  default_tags {
    tags = var.default_tags
  }
}

#### Obtain details about the account being used to execute changes in AWS
data "aws_caller_identity" "current" {}