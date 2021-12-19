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

#-----------------------------------------------------------------------------------------
# 1. VPC
#-----------------------------------------------------------------------------------------
resource "aws_vpc" "default" {
  cidr_block = "12.13.0.0/16"
}
resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id
}



#-----------------------------------------------------------------------------------------
# 3. Instance
#-----------------------------------------------------------------------------------------
# resource "aws_instance" {
# }
