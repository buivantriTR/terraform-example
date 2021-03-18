terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "ap-southeast-1"
}

module "ec2-module" {
  source  = "bvtitr.scalr.io/env-tc8jninou6pvht0/ec2-module/aws"
  version = "0.1.2"
  # number_of_instances = 2
  # ami_instance        = "ami-0f86a70488991335e"
  # instance_type       = "t2.micro"
  # key_name            = "trvm"

  number_of_instances = var.number_of_instances
  ami_instance        = var.ami_instance
  instance_type       = var.instance_type
  key_name            = var.key_name
  region              = var.region
}

# Create new VPC
resource "aws_vpc" "tr_vpc" {
  cidr_block = "10.0.0.0/16"
}

# Create new gateway
resource "aws_internet_gateway" "tr_gw" {
  vpc_id = aws_vpc.tr_vpc.id

  tags = {
    Name = "Prod"
  }
}

# Create new route table
resource "aws_route_table" "tr_r" {
  vpc_id = aws_vpc.tr_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tr_gw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.tr_gw.id
  }

  tags = {
    Name = "Prod"
  }
}

# Create new subnet
resource "aws_subnet" "tr_sn" {
  vpc_id            = aws_vpc.tr_vpc.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "ap-southeast-1a"

  tags = {
    Name = "Prod"
  }
}

# Create new subnet association
resource "aws_route_table_association" "tr_sna" {
  subnet_id      = aws_subnet.tr_sn.id
  route_table_id = aws_route_table.tr_r.id
}

# Create new security groups
resource "aws_security_group" "tr_sg_01" {
  name        = "Tr Security Group 01"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.tr_vpc.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Tr SG"
  }
}

# Create new network interface
resource "aws_network_interface" "tr_ni" {
  subnet_id       = aws_subnet.tr_sn.id
  private_ips     = ["10.0.0.50", "10.0.0.51"]
  security_groups = [aws_security_group.tr_sg_01.id]
}

# Ass new EIP
resource "aws_eip" "one" {
  vpc                       = true
  network_interface         = aws_network_interface.tr_ni.id
  associate_with_private_ip = "10.0.0.50"

  depends_on = [aws_internet_gateway.tr_gw]
}

resource "aws_eip" "two" {
  vpc                       = true
  network_interface         = aws_network_interface.tr_ni.id
  associate_with_private_ip = "10.0.0.51"

  depends_on = [aws_internet_gateway.tr_gw]
}

