module "s3" {
  source              = "./modules/s3_bucket"
  bucket_name_prefix  = var.bucket_name_prefix
  environment         = var.environment
  project             = var.project
  versioning_enabled  = true
  force_destroy       = false
}

module "ec2" {
  source               = "./modules/ec2_instance"
  environment          = var.environment
  project              = var.project
  instance_type        = var.ec2_instance_type
  ami_id               = var.ec2_ami_id
  key_name             = var.ec2_key_name
  ingress_cidr_blocks  = var.ingress_cidr_blocks
}

output "s3_bucket_name" {
  value       = module.s3.bucket_name
  description = "Created S3 bucket name"
}

output "ec2_public_ip" {
  value       = module.ec2.public_ip
  description = "Public IP of EC2 instance"
}


