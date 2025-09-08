# ---- Stage 1: Build the JAR ----
FROM maven:3.9.6-eclipse-temurin-17 AS build
WORKDIR /app

# Copy Maven wrapper, pom.xml, and wrapper folder
COPY pom.xml mvnw ./
COPY wrapper ./wrapper

# Give mvnw executable permission
RUN chmod +x mvnw

# Download dependencies
RUN ./mvnw dependency:go-offline -B

# Copy source code
COPY src ./src

# Build jar (skip tests for faster build)
RUN ./mvnw clean package -DskipTests


# ---- Stage 2: Run the JAR ----
FROM eclipse-temurin:17-jdk-alpine
WORKDIR /app

# Copy the jar from build stage
COPY --from=build /app/target/*.jar app.jar

# Expose Render’s dynamic port (will be mapped from $PORT)
EXPOSE 8080

# Run the app
ENTRYPOINT ["java", "-jar", "app.jar"]
