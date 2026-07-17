output "db_instance_id" {
  description = "RDS instance ID"
  value       = aws_db_instance.main.id
}

output "db_address" {
  description = "RDS hostname"
  value       = aws_db_instance.main.address
}

output "db_endpoint" {
  description = "RDS endpoint with port"
  value       = aws_db_instance.main.endpoint
}

output "db_port" {
  description = "RDS database port"
  value       = aws_db_instance.main.port
}

output "master_user_secret_arn" {
  description = "Secrets Manager ARN for the RDS master credentials"
  value       = aws_db_instance.main.master_user_secret[0].secret_arn
}
