output "ec2_instance_id" {
  description = "Product Store application EC2 instance ID."
  value       = module.ec2.instance_id
}

output "ec2_public_ip" {
  description = "Public IPv4 address for initial application access."
  value       = module.ec2.public_ip
}

output "application_url" {
  description = "Initial HTTP URL. The application must be deployed and listening on port 8080."
  value       = "http://${module.ec2.public_ip}:8080"
}

output "rds_endpoint" {
  description = "RDS endpoint hostname and port."
  value       = module.rds.endpoint
}

output "rds_database_name" {
  description = "Initial MySQL database name."
  value       = var.db_name
}

output "vpc_id" {
  description = "Product Store VPC ID."
  value       = module.vpc.vpc_id
}
