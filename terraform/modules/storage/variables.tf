
variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "bucket_suffix" {
  description = "Unique suffix for the S3 bucket name"
  type        = string
}

variable "noncurrent_version_expiration_days" {
  description = "Days before noncurrent object versions expire"
  type        = number
  default     = 90
}
