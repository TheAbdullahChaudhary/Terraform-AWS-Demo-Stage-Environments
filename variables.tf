variable "project" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., demo, stage)"
  type        = string
}

variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "ec2_instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "ec2_key_name" {
  description = "Existing EC2 key pair name for SSH access"
  type        = string
}

variable "ec2_ami_id" {
  description = "Optional AMI ID override"
  type        = string
  default     = ""
}

variable "ingress_cidr_blocks" {
  description = "CIDR blocks allowed for SSH/HTTP to EC2"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "bucket_name_prefix" {
  description = "Prefix for S3 bucket name"
  type        = string
}


