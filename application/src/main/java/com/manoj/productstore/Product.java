package com.manoj.productstore;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.PositiveOrZero;
import software.amazon.awssdk.enhanced.dynamodb.mapper.annotations.DynamoDbAttribute;
import software.amazon.awssdk.enhanced.dynamodb.mapper.annotations.DynamoDbBean;
import software.amazon.awssdk.enhanced.dynamodb.mapper.annotations.DynamoDbPartitionKey;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

@DynamoDbBean
public class Product {
    private String productId;
    @NotBlank
    private String name;
    private String description;
    @NotNull
    @DecimalMin("0.00")
    private BigDecimal price;
    @NotNull
    @PositiveOrZero
    private Integer quantity;
    private Instant createdAt;

    @DynamoDbPartitionKey
    @DynamoDbAttribute("productId")
    public String getProductId() { return productId; }
    public void setProductId(String productId) { this.productId = productId; }

    @DynamoDbAttribute("name")
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    @DynamoDbAttribute("description")
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    @DynamoDbAttribute("price")
    public BigDecimal getPrice() { return price; }
    public void setPrice(BigDecimal price) { this.price = price; }

    @DynamoDbAttribute("quantity")
    public Integer getQuantity() { return quantity; }
    public void setQuantity(Integer quantity) { this.quantity = quantity; }

    @DynamoDbAttribute("createdAt")
    public Instant getCreatedAt() { return createdAt; }
    public void setCreatedAt(Instant createdAt) { this.createdAt = createdAt; }

    public void initializeForCreate() {
        if (productId == null || productId.isBlank()) {
            productId = UUID.randomUUID().toString();
        }
        if (createdAt == null) {
            createdAt = Instant.now();
        }
    }
}
