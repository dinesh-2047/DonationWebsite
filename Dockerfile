# ---- Stage 1: Build the JAR ----
FROM maven:3.9.6-eclipse-temurin-17 AS build
WORKDIR /app

# Copy Maven wrapper + pom.xml
COPY pom.xml .
COPY mvnw .
COPY wrapper ./wrapper

# Download dependencies
RUN ./mvnw dependency:go-offline -B

# Copy source code
COPY src ./src

# Build jar
RUN ./mvnw clean package -DskipTests

# ---- Stage 2: Run the JAR ----
FROM eclipse-temurin:17-jdk-alpine
WORKDIR /app

# Copy jar from build stage
COPY --from=build /app/target/*.jar app.jar

# Render uses $PORT env var
EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
