output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "app_subnet_ids" {
  description = "Private application subnet IDs"
  value       = module.vpc.app_subnet_ids
}

output "db_subnet_ids" {
  description = "Isolated database subnet IDs"
  value       = module.vpc.db_subnet_ids
}

output "nat_gateway_id" {
  description = "NAT Gateway ID"
  value       = module.vpc.nat_gateway_id
}

output "nat_public_ip" {
  description = "NAT Gateway public IP"
  value       = module.vpc.nat_public_ip
}

output "alb_security_group_id" {
  description = "ALB security group ID"
  value       = module.security.alb_security_group_id
}

output "app_security_group_id" {
  description = "Application security group ID"
  value       = module.security.app_security_group_id
}

output "rds_security_group_id" {
  description = "RDS security group ID"
  value       = module.security.rds_security_group_id
}

output "alb_dns_name" {
  description = "Application Load Balancer DNS name"
  value       = module.alb.alb_dns_name
}

output "alb_arn" {
  description = "Application Load Balancer ARN"
  value       = module.alb.alb_arn
}

output "target_group_arn" {
  description = "Application target group ARN"
  value       = module.alb.target_group_arn
}

output "launch_template_id" {
  description = "Launch Template ID"
  value       = module.launch_template.launch_template_id
}

output "ec2_iam_role_name" {
  description = "IAM role assigned to application instances"
  value       = module.launch_template.iam_role_name
}

output "autoscaling_group_name" {
  description = "Auto Scaling Group name"
  value       = module.autoscaling.autoscaling_group_name
}

output "autoscaling_policy_arn" {
  description = "Auto Scaling target tracking policy ARN"
  value       = module.autoscaling.autoscaling_policy_arn
}

output "db_address" {
  description = "RDS database hostname"
  value       = module.rds.db_address
}

output "db_endpoint" {
  description = "RDS endpoint with port"
  value       = module.rds.db_endpoint
}

output "db_port" {
  description = "RDS port"
  value       = module.rds.db_port
}

output "db_master_secret_arn" {
  description = "Secrets Manager ARN for RDS master credentials"
  value       = module.rds.master_user_secret_arn
}

output "sns_topic_arn" {
  description = "SNS alerts topic ARN"
  value       = module.sns.topic_arn
}

output "cloudwatch_dashboard_name" {
  description = "CloudWatch dashboard name"
  value       = module.monitoring.dashboard_name
}

output "storage_bucket_id" {
  description = "S3 storage bucket ID"
  value       = module.storage.bucket_id
}

output "storage_bucket_arn" {
  description = "S3 storage bucket ARN"
  value       = module.storage.bucket_arn
}

output "storage_bucket_name" {
  description = "S3 storage bucket name"
  value       = module.storage.bucket_name
}

output "storage_bucket_region" {
  description = "S3 storage bucket region"
  value       = module.storage.bucket_region
}
