terraform {
  required_version = ">= 1.4.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_ami" "amazon_linux_2" {
  count = var.ami_id == "" ? 1 : 0
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

locals {
  common_tags = merge({
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
    Module      = "ec2_instance"
  }, var.additional_tags)
}

data "aws_vpc" "default" {
  count = var.vpc_id == "" ? 1 : 0
  default = true
}

data "aws_subnets" "default_public" {
  count  = var.subnet_id == "" ? 1 : 0
  filter {
    name   = "vpc-id"
    values = [var.vpc_id != "" ? var.vpc_id : data.aws_vpc.default[0].id]
  }
}

resource "aws_security_group" "instance_sg" {
  name        = "${var.project}-${var.environment}-ec2-sg"
  description = "Security group for EC2 instance"
  vpc_id      = var.vpc_id != "" ? var.vpc_id : data.aws_vpc.default[0].id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ingress_cidr_blocks
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.ingress_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = local.common_tags
}

resource "aws_instance" "this" {
  ami                         = var.ami_id != "" ? var.ami_id : data.aws_ami.amazon_linux_2[0].id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = var.subnet_id != "" ? var.subnet_id : data.aws_subnets.default_public[0].ids[0]
  vpc_security_group_ids      = [aws_security_group.instance_sg.id]
  associate_public_ip_address = var.associate_public_ip

  tags = local.common_tags
}

output "instance_id" {
  value       = aws_instance.this.id
  description = "EC2 instance ID"
}

output "public_ip" {
  value       = aws_instance.this.public_ip
  description = "Public IP of the EC2 instance"
}

output "security_group_id" {
  value       = aws_security_group.instance_sg.id
  description = "Security group ID"
}


