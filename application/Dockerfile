# Build the Spring Boot application with Java 21.
FROM maven:3.9.9-eclipse-temurin-21 AS build
WORKDIR /workspace

COPY pom.xml .
RUN mvn -B -DskipTests dependency:go-offline

COPY src ./src
RUN mvn -B -DskipTests clean package

# Run with a minimal Java 21 runtime.
FROM eclipse-temurin:21-jre
WORKDIR /app

RUN groupadd --system spring && useradd --system --gid spring --home-dir /app spring
COPY --from=build --chown=spring:spring /workspace/target/product-store.jar /app/product-store.jar

ENV SERVER_PORT=8080
EXPOSE 8080

USER spring
ENTRYPOINT ["java", "-XX:MaxRAMPercentage=75.0", "-jar", "/app/product-store.jar"]
