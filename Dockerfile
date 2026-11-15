FROM eclipse-temurin:11-jre

WORKDIR /app

COPY target/*.jar app.jar

ENTRYPOINT ["java", "-cp", "app.jar", "Hello"]