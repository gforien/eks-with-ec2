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
# 1. VPC, IG, route table, SG
#-----------------------------------------------------------------------------------------
resource "aws_vpc" "default" {
  cidr_block = "12.13.0.0/16"
}
resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id
}
resource "aws_route_table" "default" {
  vpc_id = aws_vpc.default.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.default.id
  }
}
resource "aws_security_group" "default" {
  vpc_id = aws_vpc.default.id
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 80
    protocol    = "tcp"
  }
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 443
    protocol    = "tcp"
  }
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 22
    protocol    = "ssh"
  }
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = -1
  }
}


#-----------------------------------------------------------------------------------------
# 2. Subnet, NIC, route-table association
#-----------------------------------------------------------------------------------------
resource "aws_subnet" "default" {
  vpc_id = aws_vpc.default.id
  cidr_block = "12.13.14.0/24"

  # Subnets have to be allowed to automatically map public IP addresses for worker nodes
  map_public_ip_on_launch = true
}
resource "aws_network_interface" "default" {
  subnet_id = aws_subnet.default.id
  security_groups = [aws_security_group.default.id]
}
resource "aws_route_table_association" "default" {
  subnet_id = aws_subnet.default.id
  route_table_id = aws_route_table.default.id
}

#-----------------------------------------------------------------------------------------
# 3. Instance
#-----------------------------------------------------------------------------------------
# resource "aws_instance" {
# }
