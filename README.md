# Product Store — Terraform Infrastructure

Terraform provisions an AWS VPC, an Ubuntu EC2 application server, and an on-demand Amazon DynamoDB table. The Spring Boot application can access DynamoDB through an EC2 instance profile; no database password or static AWS access key is stored in Terraform variables.

## Architecture

- Public subnet: Ubuntu EC2 application server (port 8080 restricted to `app_ingress_cidr`)
- DynamoDB: on-demand table `products` with string partition key `productId`, point-in-time recovery enabled
- EC2 instance profile: least-privilege DynamoDB item access to the Product Store table
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

This branch replaces the old RDS Terraform module with DynamoDB. Applying it against an existing Terraform state can plan to destroy the RDS instance and its database. Back up and export any data first, inspect `terraform plan` carefully, and do not apply a plan that destroys a database you still need. Terraform does not automatically migrate SQL rows into DynamoDB.

## Cost and security

- DynamoDB uses on-demand billing and point-in-time recovery. Review current AWS pricing for your workload.
- EC2 access is scoped by security group CIDRs. Restrict SSH and HTTP ingress to trusted addresses.
- The app role grants only item operations on this table plus Scan. Do not attach broad DynamoDB permissions.
- Use HTTPS through a load balancer or reverse proxy for production.
- Protect Terraform state and never commit state files or credentials.


## Container deployment

The Spring Boot application is containerized from the `application/` directory. It listens on `0.0.0.0:8080` inside the container and uses the AWS SDK default credential chain. On EC2, attach the Terraform-created instance profile; do not pass AWS access keys into the container.

### Build and run locally

From the repository root:

```bash
docker build -t product-store:local ./application
docker run --rm -p 8080:8080 \
  -e AWS_REGION=ap-south-1 \
  -e DYNAMODB_TABLE=products \
  product-store:local
```

The host must have AWS credentials configured (or use an attached EC2 instance role). The role needs the DynamoDB item permissions documented above.

### Publish to a registry

For example, with Docker Hub:

```bash
docker login
docker build -t YOUR_DOCKERHUB_USERNAME/product-store:latest ./application
docker push YOUR_DOCKERHUB_USERNAME/product-store:latest
```

Set `docker_image` in `terraform.tfvars` to that exact image reference. The EC2 user-data script pulls and runs it on port 8080.

### Allow public internet access

Set `app_ingress_cidr = "0.0.0.0/0"` in `terraform.tfvars` to make TCP/80 and TCP/8080 reachable from the internet. Port 80 is the normal browser URL; port 8080 is also available for direct testing. Keep `admin_cidr` restricted to your own public IP (/32); SSH is not opened publicly by this setting.

Then run:

```bash
terraform init
terraform validate
terraform plan
terraform apply
terraform output application_url
```

Also confirm the EC2 subnet has a route to an Internet Gateway and the instance has a public IPv4 address. The current VPC module provides both. This exposes plain HTTP; use a domain and HTTPS reverse proxy or load balancer before production use.

**Important:** Terraform user-data runs when an instance is first created (or when the instance is replaced under the applicable lifecycle behavior). Changing the image variable alone may not automatically restart an already-running container; deploy a new image explicitly or replace/reprovision the instance after reviewing `terraform plan`.


### Build and publish the image before applying Terraform

The EC2 bootstrap pulls the image configured in `docker_image`. A practical public-image workflow is:

```bash
cd application
docker build -t YOUR_DOCKERHUB_USERNAME/product-store:latest .
docker login
docker push YOUR_DOCKERHUB_USERNAME/product-store:latest
cd ..
```

Set `docker_image` in `terraform.tfvars` to `YOUR_DOCKERHUB_USERNAME/product-store:latest` before `terraform apply`. If using GHCR or a private registry, configure an image-pull authentication mechanism on EC2; the sample bootstrap assumes the image is publicly pullable.

To test the app after deployment, run:

```bash
curl -i http://$(terraform output -raw ec2_public_ip)/api/products
curl -i http://$(terraform output -raw ec2_public_ip):8080/api/products
```

The API requires a reachable DynamoDB table and an EC2 instance profile with the documented item permissions. Public access is plain HTTP and is suitable for a learning/demo deployment, not production without HTTPS and tighter ingress controls.
