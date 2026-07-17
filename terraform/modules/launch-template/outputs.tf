output "launch_template_id" {
  description = "Launch Template ID"
  value       = aws_launch_template.app.id
}

output "launch_template_latest_version" {
  description = "Latest Launch Template version"
  value       = aws_launch_template.app.latest_version
}

output "iam_role_name" {
  description = "IAM role assigned to EC2 instances"
  value       = aws_iam_role.ec2.name
}

output "instance_profile_name" {
  description = "IAM instance profile name"
  value       = aws_iam_instance_profile.ec2.name
}
