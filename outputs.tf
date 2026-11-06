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

output "dynamodb_table_name" {
  description = "DynamoDB table name used by the application."
  value       = module.dynamodb.table_name
}

output "dynamodb_table_arn" {
  description = "DynamoDB table ARN."
  value       = module.dynamodb.table_arn
}

output "ec2_instance_role_name" {
  description = "IAM role assumed by EC2 for DynamoDB access."
  value       = module.ec2.instance_role_name
}

output "vpc_id" {
  description = "Product Store VPC ID."
  value       = module.vpc.vpc_id
}
