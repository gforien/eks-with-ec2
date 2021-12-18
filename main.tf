terraform {
  required_version = "~> 1.0"
  required_providers {
    aws = {
      source  = "registry.terraform.io/hashicorp/aws"
      version = "~> 3.0"
    }
  }

}

provider "aws" {
  region = "eu-west-1"
}

# resource "aws_vpc" {
#   cidr_block = "12.13.14.15/16"
# }

# resource "aws_instance" {

# }
