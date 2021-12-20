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
  cidr_block           = "12.13.0.0/16"
  enable_dns_hostnames = true
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
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
  }
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = -1
  }
  # KUBERNETES REQUIRED PORTS
  # For master nodes
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
  }
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 2379
    to_port     = 2380
    protocol    = "tcp"
  }
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 10248
    to_port     = 10248
    protocol    = "tcp"
  }
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 10250
    to_port     = 10252
    protocol    = "tcp"
  }
  # For worker nodes
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
  }
}


#-----------------------------------------------------------------------------------------
# 2. Subnet, NIC, route-table association
#-----------------------------------------------------------------------------------------
resource "aws_subnet" "default" {
  vpc_id     = aws_vpc.default.id
  cidr_block = "12.13.14.0/24"

  # Subnets have to be allowed to automatically map public IP addresses for worker nodes
  map_public_ip_on_launch = true
}
resource "aws_network_interface" "default" {
  subnet_id       = aws_subnet.default.id
  security_groups = [aws_security_group.default.id]
}
resource "aws_route_table_association" "default" {
  subnet_id      = aws_subnet.default.id
  route_table_id = aws_route_table.default.id
}


#-----------------------------------------------------------------------------------------
# 3. Instance
#-----------------------------------------------------------------------------------------
variable "AWS_KEYNAME" {
  type        = string
  description = "Pre-existing SSH key in order to connect to an EC2."
}
variable "cluster_size" {
  type        = number
  description = "Number of EC2 instances to provision."
  default     = 1
}
variable "token" {
  type        = string
  description = "Token used for creating the K8S cluster. Use Get-K8sToken to generate one."
}
output "EC2_public_ips" {
  value = aws_instance.node.*.public_ip
}
output "EC2_public_dns" {
  value = aws_instance.node.*.public_dns
}
resource "aws_instance" "node" {
  instance_type          = "t2.micro"
  ami                    = "ami-08ca3fed11864d6bb"
  subnet_id              = aws_subnet.default.id
  vpc_security_group_ids = [aws_security_group.default.id]
  key_name               = var.AWS_KEYNAME
  count                  = var.cluster_size
  user_data              = <<-EOF
#!/bin/bash

# install docker
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg lsb-release apt-transport-https
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) \
  signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" \
  | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

sudo service docker start
sudo usermod -a -G docker ubuntu
sudo newgrp docker
docker run -p 80:80 -d hello-world
docker ps -a                                            # test

# network config
sudo modprobe br_netfilter
lsmod | grep br_netfilter                               # test

# network config 2
cat <<EOOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOOF
sudo sysctl --system | grep bridge-nf-call              # test

# check container runtime
ls -l /var/run/docker.sock                              # test

# prepare kubeadm, kubelet and kubectl installation
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
cat <<EOOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOOF
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# solution for issue #2
cat <<EOOF | sudo tee /etc/docker/daemon.json
{
    "exec-opts": ["native.cgroupdriver=systemd"]
}
EOOF
sudo systemctl daemon-reload
sudo systemctl restart docker
sudo systemctl restart kubelet

# kubeadm init \
#   --ignore-preflight-errors=NumCPU,Mem \
#   --token=${var.token}
# mkdir -p $HOME/.kube
# sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
# sudo chown $(id -u):$(id -g) $HOME/.kube/config

# kubeadm join 12.13.14.146:6443 \
#   --discovery-token-unsafe-skip-ca-verification \
#   --token=iangzw.isv0gkb5dy86n3ft
EOF
}
