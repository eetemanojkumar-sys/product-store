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
  description = "Your public IP/CIDR allowed to SSH to EC2, e.g. 203.0.113.10/32."
  type        = string
  validation {
    condition     = can(cidrnetmask(var.admin_cidr))
    error_message = "admin_cidr must be a valid IPv4 CIDR."
  }
}

variable "app_ingress_cidr" {
  description = "Public IP/CIDR allowed to access the app on port 8080. Use your IP/32."
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

variable "db_instance_class" {
  description = "RDS instance class."
  type        = string
  default     = "db.t3.micro"
}

variable "db_name" {
  description = "Initial MySQL database name."
  type        = string
  default     = "productstore"
}

variable "db_username" {
  description = "RDS master username. For production, create a separate least-privilege app user."
  type        = string
  default     = "productadmin"
}

variable "db_password" {
  description = "RDS master password. Set with TF_VAR_db_password environment variable."
  type        = string
  sensitive   = true
  nullable    = false
  validation {
    condition     = length(var.db_password) >= 12 && length(var.db_password) <= 41
    error_message = "db_password must be between 12 and 41 characters."
  }
}

variable "db_allocated_storage" {
  description = "Initial RDS allocated storage in GiB."
  type        = number
  default     = 20
}
