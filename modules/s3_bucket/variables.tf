variable "bucket_name_prefix" {
  description = "Prefix for the S3 bucket name. A random suffix will be added for global uniqueness."
  type        = string
}

variable "environment" {
  description = "Environment name tag (e.g., demo, stage)."
  type        = string
}

variable "project" {
  description = "Project name tag."
  type        = string
}

variable "versioning_enabled" {
  description = "Enable versioning on the bucket."
  type        = bool
  default     = true
}

variable "force_destroy" {
  description = "When true, allows Terraform to delete non-empty buckets (use with caution)."
  type        = bool
  default     = false
}


