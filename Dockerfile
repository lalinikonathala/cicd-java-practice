From eclipse-temurin:11-jre
Workdir /app
copy target/*.jar app.jar
ENTRYPOINT ["java","-cp","app.jar","Hello"]
