output "table_name" {
  value = aws_dynamodb_table.products.name
}

output "table_arn" {
  value = aws_dynamodb_table.products.arn
}

output "users_table_name" {
  value = aws_dynamodb_table.users.name
}

output "users_table_arn" {
  value = aws_dynamodb_table.users.arn
}
