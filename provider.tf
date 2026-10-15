provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "product-store"
      ManagedBy   = "Terraform"
      Environment = var.environment
    }
  }
}
