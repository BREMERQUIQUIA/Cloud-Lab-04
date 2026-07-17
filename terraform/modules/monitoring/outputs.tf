output "dashboard_name" {
  description = "CloudWatch dashboard name"
  value       = aws_cloudwatch_dashboard.main.dashboard_name
}

output "asg_high_cpu_alarm_name" {
  description = "Auto Scaling high CPU alarm name"
  value       = aws_cloudwatch_metric_alarm.asg_high_cpu.alarm_name
}

output "alb_unhealthy_hosts_alarm_name" {
  description = "ALB unhealthy targets alarm name"
  value       = aws_cloudwatch_metric_alarm.alb_unhealthy_hosts.alarm_name
}
