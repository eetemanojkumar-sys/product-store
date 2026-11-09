variable "project_name" { type = string }
variable "vpc_id" { type = string }
variable "public_subnet_id" { type = string }
variable "admin_cidr" { type = string }
variable "app_ingress_cidr" { type = string }
variable "key_name" { type = string }
variable "instance_type" { type = string }
variable "dynamodb_table_arn" { type = string }
variable "dynamodb_table_name" { type = string }

variable "docker_image" {
  description = "Product Store container image to deploy on EC2."
  type        = string
  default     = "YOUR_DOCKERHUB_USERNAME/product-store:latest"
}
