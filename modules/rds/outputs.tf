output "endpoint" {
  description = "RDS endpoint hostname and port for application configuration."
  value       = aws_db_instance.this.endpoint
}

output "address" {
  value = aws_db_instance.this.address
}

output "port" {
  value = aws_db_instance.this.port
}

output "db_security_group_id" {
  value = aws_security_group.db.id
}
