project             = "new-project"
environment         = "stage"
aws_region          = "us-east-1"

# Replace with an existing key pair name in your account/region
ec2_key_name        = "your-keypair-name"
ec2_instance_type   = "t3.small"

bucket_name_prefix  = "new-project-stage-bucket"

# For security, restrict to your office/home IP where possible
ingress_cidr_blocks = ["0.0.0.0/0"]


