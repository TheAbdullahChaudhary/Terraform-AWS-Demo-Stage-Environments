variable "environment" {
  description = "Environment name tag (e.g., demo, stage)."
  type        = string
}

variable "project" {
  description = "Project name tag."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "AMI ID to use. If empty, a latest Amazon Linux 2 AMI in the region will be looked up."
  type        = string
  default     = ""
}

variable "key_name" {
  description = "Name of an existing EC2 Key Pair to enable SSH access."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID to deploy into. If empty, default VPC is used."
  type        = string
  default     = ""
}

variable "subnet_id" {
  description = "Subnet ID to deploy into. If empty, the first default public subnet is used."
  type        = string
  default     = ""
}

variable "associate_public_ip" {
  description = "Associate a public IP address with the instance."
  type        = bool
  default     = true
}

variable "ingress_cidr_blocks" {
  description = "List of CIDR blocks allowed to access the instance on SSH (22) and HTTP (80)."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "additional_tags" {
  description = "Additional tags to apply to resources."
  type        = map(string)
  default     = {}
}


