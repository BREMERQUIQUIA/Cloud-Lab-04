output "alb_arn" {
  description = "Application Load Balancer ARN"
  value       = aws_lb.main.arn
}

output "alb_dns_name" {
  description = "Application Load Balancer DNS name"
  value       = aws_lb.main.dns_name
}

output "alb_zone_id" {
  description = "Application Load Balancer Route 53 zone ID"
  value       = aws_lb.main.zone_id
}

output "target_group_arn" {
  description = "Application target group ARN"
  value       = aws_lb_target_group.app.arn
}

output "http_listener_arn" {
  description = "HTTP listener ARN"
  value       = aws_lb_listener.http.arn
}

output "alb_arn_suffix" {
  description = "Application Load Balancer ARN suffix for CloudWatch dimensions"
  value       = aws_lb.main.arn_suffix
}

output "target_group_arn_suffix" {
  description = "Target Group ARN suffix for CloudWatch dimensions"
  value       = aws_lb_target_group.app.arn_suffix
}
