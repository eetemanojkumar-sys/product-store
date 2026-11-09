data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source       = "./modules/vpc"
  project_name = var.project_name
  vpc_cidr     = var.vpc_cidr
  azs          = slice(data.aws_availability_zones.available.names, 0, 2)
}

module "dynamodb" {
  source             = "./modules/dynamodb"
  project_name       = var.project_name
  table_name         = var.dynamodb_table_name
  point_in_time_recovery = var.dynamodb_point_in_time_recovery
}

module "ec2" {
  source              = "./modules/ec2"
  project_name        = var.project_name
  vpc_id              = module.vpc.vpc_id
  public_subnet_id    = module.vpc.public_subnet_id
  admin_cidr          = var.admin_cidr
  app_ingress_cidr    = var.app_ingress_cidr
  key_name            = var.key_name
  instance_type       = var.instance_type
  dynamodb_table_arn  = module.dynamodb.table_arn
  dynamodb_table_name = module.dynamodb.table_name
  docker_image        = var.docker_image
}
