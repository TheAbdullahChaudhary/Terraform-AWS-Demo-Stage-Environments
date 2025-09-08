## Terraform AWS Demo/Stage Environments (EC2 + S3)

This repo provides an end-to-end, production-ready baseline to create a new AWS environment (demo or stage) using Terraform. It provisions:

- An S3 bucket (private, versioned, encrypted, public access blocked)
- An EC2 instance (Amazon Linux 2 by default) with a minimal security group

It is structured to support multiple environments via tfvars files and standard tagging.

### Who is this for?

This guide is written to be step-by-step and self-contained. Follow it to create either a Demo or a Stage environment on AWS using Infrastructure as Code.

---

### Prerequisites

- AWS account with permissions to manage EC2, S3, VPC, IAM
- An existing EC2 Key Pair in the target region (to SSH into the instance)
- Installed locally:
  - Terraform >= 1.4
  - AWS CLI v2
  - PowerShell (Windows)

### Step 1: Install and set up your tools (Windows)

1) Install Terraform
   - Download from the official site and follow the installer.
   - After installation, verify in PowerShell:
   ```powershell
   terraform -version
   ```

2) Install AWS CLI v2
   - Download and install AWS CLI v2.
   - Verify:
   ```powershell
   aws --version
   ```

3) Optional: Install OpenSSH Client (for SSH into EC2)
   - On most recent Windows versions, OpenSSH Client is available by default.
   - Verify:
   ```powershell
   ssh -V
   ```

---

### Step 2: Create an AWS IAM user and access keys

You need an AWS IAM user with permissions to create EC2, S3, VPC, and networking resources.

1) In AWS Console: IAM → Users → Add users
   - Username: e.g., terraform-admin
   - Access type: "Provide user access to the AWS Management Console" is optional; required is "Access key - Programmatic access".
   - Permissions: Attach a policy with needed privileges (for learning, AdministratorAccess is simplest; for production, use least-privilege policies).
   - Download the CSV with `Access key ID` and `Secret access key`.

2) Configure credentials locally (PowerShell):
   ```powershell
   aws configure --profile default
   # Paste Access key ID, Secret access key, and set default region (e.g., us-east-1)
   ```

You can also export environment variables for a one-time session:
```powershell
$env:AWS_ACCESS_KEY_ID="<YOUR_ACCESS_KEY_ID>"
$env:AWS_SECRET_ACCESS_KEY="<YOUR_SECRET_ACCESS_KEY>"
$env:AWS_DEFAULT_REGION="us-east-1"
```

---

### Step 3: Create an EC2 Key Pair (for SSH)

You need an existing EC2 Key Pair name in the same region to SSH into the instance.

Option A: Create via AWS Console
- EC2 → Key Pairs → Create key pair
- Name: e.g., new-project-key
- Key pair type: RSA
- Private key format: PEM
- Save the downloaded .pem file securely

Option B: Create via AWS CLI
```powershell
aws ec2 create-key-pair --key-name new-project-key --query 'KeyMaterial' --output text > $HOME\new-project-key.pem
# Restrict permissions on the key (Windows)
icacls $HOME\new-project-key.pem /inheritance:r
icacls $HOME\new-project-key.pem /grant:r $($env:USERNAME):R
```

Use the key pair name (e.g., `new-project-key`) in the tfvars files.

---

### Authentication

Configure your AWS credentials using one of the supported methods. Common options:

1. Set a default profile (recommended):
   ```powershell
   aws configure --profile default
   ```
2. Or export env vars for a specific session:
   ```powershell
   $env:AWS_ACCESS_KEY_ID="AKIA..."
   $env:AWS_SECRET_ACCESS_KEY="..."
   $env:AWS_DEFAULT_REGION="us-east-1"
   ```

### Project Structure

```text
terraform/
  main.tf
  variables.tf
  providers.tf
  versions.tf
  modules/
    s3_bucket/
      main.tf
      variables.tf
      outputs.tf
    ec2_instance/
      main.tf
      variables.tf
  environments/
    demo.tfvars
    stage.tfvars
```

### What gets created

- S3 bucket with name pattern: `<bucket_name_prefix>-<environment>-<random>`
  - Versioning: Enabled
  - Server-side encryption: AES256 (SSE-S3)
  - Public access: Fully blocked
- EC2 instance
  - Amazon Linux 2 AMI (auto-discovered) unless `ec2_ami_id` is set
  - Security group allows SSH (22) and HTTP (80); you can restrict `ingress_cidr_blocks`
  - Public IP associated by default

### Quick Start (PowerShell)

1. Navigate to the Terraform folder:
   ```powershell
   cd D:\HUS\STAGES-WORK\terraform
   ```

2. Initialize providers and modules:
   ```powershell
   terraform init
   ```

3. Review the plan for demo:
   ```powershell
   terraform plan -var-file="environments/demo.tfvars"
   ```

4. Apply for demo:
   ```powershell
   terraform apply -auto-approve -var-file="environments/demo.tfvars"
   ```

5. Fetch outputs:
   ```powershell
   terraform output
   ```

6. Repeat for stage by switching tfvars:
   ```powershell
   terraform plan -var-file="environments/stage.tfvars"
   terraform apply -auto-approve -var-file="environments/stage.tfvars"
   ```

---

### Verify the environment

After apply completes, verify resources were created:

- S3 bucket:
  - In AWS Console → S3 → Find the bucket name printed in `terraform output s3_bucket_name`.
  - Confirm public access is blocked, versioning enabled, encryption set to SSE-S3.

- EC2 instance:
  - In AWS Console → EC2 → Instances → Confirm the instance is running and has a public IP.
  - From PowerShell, get the public IP:
    ```powershell
    terraform output ec2_public_ip
    ```

---

### SSH into the EC2 instance

1) Ensure the private key file is on your machine and permissions are restricted (see Step 3 for `icacls`).

2) Connect (replace paths and IP):
```powershell
ssh -i $HOME\new-project-key.pem ec2-user@<PUBLIC_IP>
```

If you get a permission error on the key file, re-apply the `icacls` commands to restrict access to your user only.

---

### Important Variables

- `project` (string): Project tag
- `environment` (string): `demo` or `stage`
- `aws_region` (string): AWS region
- `ec2_key_name` (string): Existing EC2 Key Pair name
- `ec2_instance_type` (string): e.g., `t3.micro`
- `ingress_cidr_blocks` (list(string)): allowed CIDRs for SSH/HTTP
- `bucket_name_prefix` (string): prefix for S3 bucket name

See `environments/*.tfvars` for examples.

### Cost awareness

- EC2 `t3.micro`/`t3.small` and one S3 bucket are low-cost but not free. Shut down when not needed.
- Storage, data transfer, and IP usage can add costs over time.

---

### Clean Up

To destroy all resources for an environment:
```powershell
terraform destroy -auto-approve -var-file="environments/demo.tfvars"
```

Note: Buckets with objects cannot be destroyed unless `force_destroy` is enabled in the module. Default is safe (false).

---

### Security Notes

- Restrict `ingress_cidr_blocks` to known IPs instead of `0.0.0.0/0`.
- Consider using a custom KMS key for S3 encryption if compliance requires it.
- Use separate AWS accounts or at least distinct IAM roles for demo/stage/production.

---

### Troubleshooting (common errors)

- AccessDenied / UnrecognizedClientException
  - Cause: Invalid or missing credentials. Fix via `aws configure` or env variables. Check account/region.

- InvalidKeyPair.NotFound
  - Cause: `ec2_key_name` does not exist in the selected region.
  - Fix: Create the key pair in the same region and update the tfvars.

- No default VPC found
  - Cause: The module looks up the default VPC when no VPC is specified; your account/region may not have one.
  - Fix: Add or reference a VPC/subnet, or add a VPC module and wire the subnet ID into the EC2 module.

- S3 bucket already exists
  - Cause: S3 bucket names are globally unique.
  - Fix: Change `bucket_name_prefix` to a unique value.

- Bucket not empty (destroy fails)
  - Cause: S3 has objects/versions.
  - Fix: Empty the bucket first, or enable `force_destroy` in the S3 module (use cautiously).

---

### Optional: Use remote state (S3 backend)

For team collaboration, store Terraform state in an S3 bucket and lock with DynamoDB.

1) Create (or reuse) a separate S3 bucket for state, and a DynamoDB table for locks.
2) Add a backend block (example):
```hcl
terraform {
  backend "s3" {
    bucket         = "my-tf-state-bucket"
    key            = "new-project/${var.environment}/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "my-tf-locks"
    encrypt        = true
  }
}
```
3) Re-initialize:
```powershell
terraform init -migrate-state
```

Keep state buckets separate from workload buckets. Apply IAM least privilege to protect state.

---

### Next steps

- Add a dedicated VPC module and avoid using the default VPC in production.
- Put your app on the EC2 instance or swap to an autoscaling group + load balancer.
- Add a KMS CMK for S3 encryption if required by compliance.

- Add additional modules (RDS, ALB, VPC) and wire them in `main.tf`.
- Replace default VPC/subnet discovery with a dedicated VPC module for stricter control.


