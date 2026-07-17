output "autoscaling_group_name" {
  description = "Auto Scaling Group name"
  value       = aws_autoscaling_group.app.name
}

output "autoscaling_group_arn" {
  description = "Auto Scaling Group ARN"
  value       = aws_autoscaling_group.app.arn
}

output "autoscaling_policy_arn" {
  description = "Target tracking scaling policy ARN"
  value       = aws_autoscaling_policy.target_tracking_cpu.arn
}
