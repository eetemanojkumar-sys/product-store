package com.manoj.productstore;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Repository;
import software.amazon.awssdk.enhanced.dynamodb.DynamoDbEnhancedClient;
import software.amazon.awssdk.enhanced.dynamodb.DynamoDbTable;
import software.amazon.awssdk.enhanced.dynamodb.TableSchema;

import java.util.Optional;

@Repository
public class UserRepository {
    private final DynamoDbTable<User> table;

    public UserRepository(DynamoDbEnhancedClient client,
                          @Value("${app.dynamodb.users-table-name:product-store-users}") String tableName) {
        this.table = client.table(tableName, TableSchema.fromBean(User.class));
    }

    public Optional<User> findByEmail(String email) {
        return Optional.ofNullable(table.getItem(key -> key.partitionValue(email)));
    }

    public void save(User user) {
        table.putItem(user);
    }
}
