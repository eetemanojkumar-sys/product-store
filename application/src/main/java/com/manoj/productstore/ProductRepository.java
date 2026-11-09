package com.manoj.productstore;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Repository;
import software.amazon.awssdk.enhanced.dynamodb.DynamoDbEnhancedClient;
import software.amazon.awssdk.enhanced.dynamodb.DynamoDbTable;
import software.amazon.awssdk.enhanced.dynamodb.Key;
import software.amazon.awssdk.enhanced.dynamodb.TableSchema;
import software.amazon.awssdk.enhanced.dynamodb.model.PageIterable;

import java.util.List;
import java.util.Optional;

@Repository
public class ProductRepository {
    private final DynamoDbTable<Product> table;

    public ProductRepository(
            DynamoDbEnhancedClient enhancedClient,
            @Value("${app.dynamodb.table-name:products}") String tableName) {
        this.table = enhancedClient.table(tableName, TableSchema.fromBean(Product.class));
    }

    public List<Product> findAll() {
        return PageIterable.create(table.scan()).items().stream().toList();
    }

    public Optional<Product> findById(String productId) {
        Key key = Key.builder().partitionValue(productId).build();
        return Optional.ofNullable(table.getItem(key));
    }

    public Product save(Product product) {
        table.putItem(product);
        return product;
    }

    public boolean existsById(String productId) {
        return findById(productId).isPresent();
    }

    public void deleteById(String productId) {
        Key key = Key.builder().partitionValue(productId).build();
        table.deleteItem(key);
    }
}
