# Product Store API

Spring Boot 3 REST API using Java 21, Spring Data JPA, and Amazon RDS MySQL.

## Endpoints

- `GET /api/products` — list products
- `GET /api/products/{id}` — get one product
- `POST /api/products` — create a product
- `PUT /api/products/{id}` — update a product
- `DELETE /api/products/{id}` — delete a product

## Build

From this directory:

```bash
mvn clean package
```

## Run

Provide the database settings through environment variables; never commit credentials.

```bash
export DB_URL='jdbc:mysql://YOUR_RDS_ENDPOINT:3306/productstore'
export DB_USERNAME='YOUR_DB_USERNAME'
read -s -p 'RDS password: ' DB_PASSWORD
echo
export DB_PASSWORD
java -jar target/product-store.jar
```

The API listens on port 8080. The EC2 security group should restrict port 8080 to the intended client IP range, and the RDS security group should allow port 3306 only from the application EC2 security group.
