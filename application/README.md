# Product Store API

Spring Boot 3 REST API using Java 21, AWS SDK for Java v2, and Amazon DynamoDB.

## Endpoints

- `GET /api/products` — list products
- `GET /api/products/{id}` — get a product by string productId
- `POST /api/products` — create a product (UUID generated when productId is omitted)
- `PUT /api/products/{id}` — update an existing product
- `DELETE /api/products/{id}` — delete a product

## Build

From this directory:

```bash
mvn clean package
```

## Run

Configure AWS credentials using an AWS profile or environment credentials locally. On EC2, use the attached instance profile; do not add static access keys.

```bash
export AWS_REGION=ap-south-1
export DYNAMODB_TABLE=products
java -jar target/product-store.jar
```

The AWS identity requires `dynamodb:DescribeTable`, `GetItem`, `PutItem`, `DeleteItem`, and `Scan` on the configured table.

## Product JSON

```json
{
  "name": "Wireless Mouse",
  "description": "Bluetooth ergonomic mouse",
  "price": 799.00,
  "quantity": 25
}
```

DynamoDB stores each product with a string `productId` partition key. The list endpoint uses Scan for this small demo; larger applications should define access patterns, indexes and pagination rather than scanning an entire table.
