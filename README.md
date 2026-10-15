# Product Store — Terraform Infrastructure

Terraform provisions a dedicated AWS VPC, one Ubuntu EC2 application server, and a private Amazon RDS for MySQL database. The Java application is deployed manually after infrastructure creation. No load balancer is included.

## Architecture
- Public subnet: Ubuntu EC2 application server (port 8080 for testing)
- Private subnets in two Availability Zones: RDS subnet group
- Security group: SSH restricted to `admin_cidr`; app port 8080 restricted to `app_ingress_cidr`
- RDS security group: MySQL 3306 only from the EC2 application security group
- RDS: private, not publicly accessible
- Terraform state: local by default. Configure remote state separately after creating an S3 bucket and (optionally) a lock table.

## Prerequisites
- Terraform >= 1.6
- AWS CLI configured with an identity allowed to create VPC, EC2, IAM, and RDS resources
- An EC2 key pair already created in the selected region
- A known public IP/CIDR for SSH and app access

## Usage
1. Copy `terraform.tfvars.example` to `terraform.tfvars`.
2. Set `admin_cidr` and `app_ingress_cidr` to your public IP with `/32`, e.g. `203.0.113.10/32`.
3. Set `key_name` to an existing EC2 key pair in the selected region.
4. Set a strong DB password through an environment variable instead of writing it into a tracked file:
   - Bash: `export TF_VAR_db_password='your-strong-password'`
   - PowerShell: `$env:TF_VAR_db_password = 'your-strong-password'`
5. Run:
   ```bash
   terraform init
   terraform fmt -recursive
   terraform validate
   terraform plan
   terraform apply
   ```
6. Retrieve outputs:
   ```bash
   terraform output
   ```
7. Connect to EC2 and manually install Java/deploy the application. Configure Spring Boot with the RDS endpoint, database `productstore`, username and password using environment variables.

## Important notes
- RDS and EC2 incur charges while running. Review AWS pricing before `apply`.
- The DB password is sensitive in Terraform output, but Terraform state can still contain it. Protect state and never commit state files.
- For production, prefer Systems Manager Session Manager instead of public SSH, HTTPS instead of exposing HTTP directly, Secrets Manager for credentials, and tighter IAM policies.
- This project deliberately has no load balancer and does not deploy application code.
- Do not run `terraform destroy` unless you intend to delete the resources. RDS deletion protection is enabled by default.
