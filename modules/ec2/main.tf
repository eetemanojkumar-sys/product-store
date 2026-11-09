data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_security_group" "app" {
  name        = "${var.project_name}-app-sg"
  description = "Allow admin SSH and configurable Product Store web access"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH from administrator IP only"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]
  }

  ingress {
    description = "HTTP access to the Product Store application"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.app_ingress_cidr]
  }

  egress {
    description = "Outbound for OS packages and AWS APIs"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project_name}-app-sg" }
}

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "app" {
  name               = "${var.project_name}-ec2-dynamodb-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
  tags               = { Name = "${var.project_name}-ec2-dynamodb-role" }
}

resource "aws_iam_role_policy" "dynamodb" {
  name = "${var.project_name}-dynamodb-access"
  role = aws_iam_role.app.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "dynamodb:DescribeTable",
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:DeleteItem",
        "dynamodb:Scan"
      ]
      Resource = var.dynamodb_table_arn
    }]
  })
}

resource "aws_iam_instance_profile" "app" {
  name = "${var.project_name}-ec2-profile"
  role = aws_iam_role.app.name
}

resource "aws_instance" "app" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = var.public_subnet_id
  vpc_security_group_ids      = [aws_security_group.app.id]
  key_name                    = var.key_name
  iam_instance_profile        = aws_iam_instance_profile.app.name
  associate_public_ip_address = true

  root_block_device {
    volume_size           = 12
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  user_data = <<-EOF
              #!/bin/bash
              # Install Docker and deploy the application image.
              apt-get update
              apt-get install -y docker.io
              # Send cloud-init output to the instance console for troubleshooting.
              exec > >(tee -a /var/log/product-store-bootstrap.log) 2>&1
              set -eux
              systemctl enable --now docker
              usermod -aG docker ubuntu
              docker pull ${var.docker_image}
              docker run -d --name product-store --restart unless-stopped \
                -p 80:8080 -p 8080:8080 \
                -e AWS_REGION="${data.aws_region.current.name}" \
                -e DYNAMODB_TABLE="${var.dynamodb_table_name}" \
                ${var.docker_image}
              EOF

  tags = { Name = "${var.project_name}-app" }
}
