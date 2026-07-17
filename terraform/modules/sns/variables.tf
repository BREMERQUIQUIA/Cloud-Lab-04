variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "notification_email" {
  description = "Email address that receives infrastructure alerts"
  type        = string
}
