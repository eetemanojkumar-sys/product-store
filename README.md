# Product Store — Terraform Infrastructure

Terraform provisions an AWS VPC, an Ubuntu EC2 application server, and an on-demand Amazon DynamoDB table. The Spring Boot application accesses DynamoDB through an EC2 instance profile; no database password or static AWS access key is stored in Terraform variables.

## Architecture

- Public subnet: Ubuntu EC2 application server (port 8080 restricted to `app_ingress_cidr`)
- DynamoDB: on-demand table `products` with string partition key `productId`, encryption and point-in-time recovery
- EC2 instance profile: least-privilege DynamoDB access to the Product Store table
- EC2 metadata service: IMDSv2 required
- Terraform state: local by default; configure remote state separately for team use

## Prerequisites

- Terraform >= 1.6
- AWS CLI configured with an identity allowed to create VPC, EC2, IAM, and DynamoDB resources
- An EC2 key pair already created in the selected region
- A known public IP/CIDR for SSH and application access

## Usage

1. Copy `terraform.tfvars.example` to `terraform.tfvars`.
2. Set `admin_cidr` and `app_ingress_cidr` to your public IP with `/32`.
3. Set `key_name` to an existing EC2 key pair in the selected region.
4. Run:

   ```bash
   terraform init
   terraform fmt -recursive
   terraform validate
   terraform plan
   terraform apply
   ```

5. Retrieve outputs with `terraform output`.
6. Deploy the application to EC2 and configure `AWS_REGION` and `DYNAMODB_TABLE`. The EC2 role supplies credentials automatically through the AWS SDK default credential chain.

## Important migration note

This branch replaces the old RDS Terraform module with DynamoDB. Applying it against an existing Terraform state can plan to destroy the RDS instance and its database. Export and back up existing SQL data first, inspect `terraform plan` carefully, and do not apply a plan that destroys a database you still need. Terraform does not automatically migrate SQL rows into DynamoDB. The current branch contains no SQL-to-DynamoDB data import utility.

## Cost and security

- DynamoDB uses on-demand billing and point-in-time recovery. Review current AWS pricing for your workload.
- EC2 access is scoped by security group CIDRs. Restrict SSH and HTTP ingress to trusted addresses.
- The app role grants item operations and Scan only on the Product Store table.
- Use HTTPS through a load balancer or reverse proxy for production.
- Protect Terraform state and never commit state files or credentials.
