variable "aws_region" {
  description = "AWS region for Product Store."
  type        = string
  default     = "ap-south-1"
}

variable "environment" {
  description = "Environment name."
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Name prefix for resources."
  type        = string
  default     = "product-store"
}

variable "vpc_cidr" {
  description = "VPC IPv4 CIDR."
  type        = string
  default     = "10.20.0.0/16"
}

variable "admin_cidr" {
  description = "Public IPv4 CIDR allowed to SSH to EC2, e.g. 203.0.113.10/32."
  type        = string
  validation {
    condition     = can(cidrnetmask(var.admin_cidr))
    error_message = "admin_cidr must be a valid IPv4 CIDR."
  }
}

variable "app_ingress_cidr" {
  description = "Public IPv4 CIDR allowed to access the app on port 8080."
  type        = string
  validation {
    condition     = can(cidrnetmask(var.app_ingress_cidr))
    error_message = "app_ingress_cidr must be a valid IPv4 CIDR."
  }
}

variable "key_name" {
  description = "Name of an existing EC2 key pair in the selected AWS region."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"
}

variable "dynamodb_table_name" {
  description = "DynamoDB table used by the Product Store application."
  type        = string
  default     = "products"
}

variable "dynamodb_point_in_time_recovery" {
  description = "Enable point-in-time recovery for the DynamoDB table."
  type        = bool
  default     = true
}

variable "dynamodb_users_table_name" {
  description = "DynamoDB table used for Product Store user accounts."
  type        = string
  default     = "product-store-users"
}
