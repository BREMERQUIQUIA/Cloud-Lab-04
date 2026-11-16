variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "availability_zones" {
  description = "Availability Zones"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
}

variable "app_subnet_cidrs" {
  description = "CIDR blocks for private application subnets"
  type        = list(string)
}

variable "db_subnet_cidrs" {
  description = "CIDR blocks for isolated database subnets"
  type        = list(string)
}

variable "instance_type" {
  description = "EC2 instance type used by the Auto Scaling Group"
  type        = string
}

variable "root_volume_size" {
  description = "Root EBS volume size in GiB"
  type        = number
  default     = 20
}

variable "asg_min_size" {
  description = "Minimum Auto Scaling Group size"
  type        = number
  default     = 2
}

variable "asg_desired_capacity" {
  description = "Desired Auto Scaling Group capacity"
  type        = number
  default     = 2
}

variable "asg_max_size" {
  description = "Maximum Auto Scaling Group size"
  type        = number
  default     = 4
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
}

variable "db_name" {
  description = "Initial database name"
  type        = string
}

variable "db_username" {
  description = "Database master username"
  type        = string
}

variable "backup_retention_period" {
  description = "RDS automated backup retention period"
  type        = number
  default     = 1
}

variable "notification_email" {
  description = "Email address for CloudWatch and Auto Scaling alerts"
  type        = string
}

variable "bucket_suffix" {
  description = "Unique suffix for the S3 bucket name"
  type        = string
}

variable "noncurrent_version_expiration_days" {
  description = "Days before noncurrent S3 object versions expire"
  type        = number
  default     = 90
}
