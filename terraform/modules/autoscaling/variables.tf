variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "app_subnet_ids" {
  description = "Private application subnet IDs"
  type        = list(string)
}

variable "launch_template_id" {
  description = "Launch Template ID"
  type        = string
}

variable "launch_template_version" {
  description = "Launch Template version"
  type        = string
}

variable "target_group_arn" {
  description = "ALB target group ARN"
  type        = string
}

variable "min_size" {
  description = "Minimum number of instances"
  type        = number
  default     = 2
}

variable "desired_capacity" {
  description = "Desired number of instances"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Maximum number of instances"
  type        = number
  default     = 4
}

variable "sns_topic_arn" {
  description = "SNS topic ARN for Auto Scaling lifecycle notifications"
  type        = string
}
