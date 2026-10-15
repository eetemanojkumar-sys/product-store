resource "aws_db_subnet_group" "this" {
  name        = "${var.project_name}-db-subnet-group"
  subnet_ids  = var.private_subnet_ids
  description = "Private subnets for Product Store RDS"

  tags = { Name = "${var.project_name}-db-subnet-group" }
}

resource "aws_security_group" "db" {
  name        = "${var.project_name}-db-sg"
  description = "Allow MySQL only from the Product Store application EC2 security group"
  vpc_id      = var.vpc_id

  ingress {
    description     = "MySQL from application tier only"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.app_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project_name}-db-sg" }
}

resource "aws_db_instance" "this" {
  identifier                  = "${var.project_name}-db"
  engine                      = "mysql"
  engine_version              = "8.0"
  instance_class              = var.db_instance_class
  allocated_storage           = var.allocated_storage
  max_allocated_storage       = var.allocated_storage + 20
  storage_type                = "gp3"
  storage_encrypted           = true

  db_name                     = var.db_name
  username                    = var.db_username
  password                    = var.db_password
  port                        = 3306

  db_subnet_group_name        = aws_db_subnet_group.this.name
  vpc_security_group_ids      = [aws_security_group.db.id]
  publicly_accessible         = false
  multi_az                    = false

  backup_retention_period     = 1
  deletion_protection         = true
  auto_minor_version_upgrade = true
  apply_immediately           = false
  skip_final_snapshot         = false
  final_snapshot_identifier   = "${var.project_name}-final-snapshot"

  tags = { Name = "${var.project_name}-db" }
}
