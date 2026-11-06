# Product Store API

Spring Boot 3 REST API using Java 21, AWS SDK for Java v2, and Amazon DynamoDB.

## Endpoints

- `GET /api/products` — scan and list products
- `GET /api/products/{id}` — get one product by its string productId
- `POST /api/products` — create a product (UUID generated when productId is omitted)
- `PUT /api/products/{id}` — update an existing product
- `DELETE /api/products/{id}` — delete a product

## Build

From this directory:

```bash
mvn clean package
```

## Run locally

Configure AWS credentials using an AWS profile or environment credentials. Do not commit access keys.

```bash
export AWS_REGION=ap-south-1
export DYNAMODB_TABLE=products
java -jar target/product-store.jar
```

The AWS identity must have `dynamodb:GetItem`, `dynamodb:PutItem`, `dynamodb:DeleteItem`, and `dynamodb:Scan` permissions for the configured table. The EC2 deployment should use an instance profile rather than static credentials.

## Product JSON

```json
{
  "name": "Wireless Mouse",
  "description": "Bluetooth ergonomic mouse",
  "price": 799.00,
  "quantity": 25
}
```

DynamoDB stores each product with a string `productId` partition key. List operations use Scan and are appropriate for this small demonstration application; use a Query-based access pattern and pagination for larger datasets.
