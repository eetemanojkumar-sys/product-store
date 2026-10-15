output "vpc_id" { value = aws_vpc.this.id }
output "public_subnet_id" { value = aws_subnet.public.id }
output "private_db_subnet_ids" { value = aws_subnet.private_db[*].id }
