variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "autoscaling_group_name" {
  description = "Auto Scaling Group name"
  type        = string
}

variable "alb_arn_suffix" {
  description = "Application Load Balancer ARN suffix"
  type        = string
}

variable "target_group_arn_suffix" {
  description = "Target Group ARN suffix"
  type        = string
}

variable "sns_topic_arn" {
  description = "SNS topic ARN used for alarm notifications"
  type        = string
}
