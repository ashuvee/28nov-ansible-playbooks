# Dockerfile for Password Generator Application
FROM tomcat:9.0.80-jdk11

# Copy the WAR file to Tomcat webapps directory
# The WAR is built as ROOT.war and will be deployed to root context
COPY target/ROOT.war /usr/local/tomcat/webapps/

# Expose Tomcat port
EXPOSE 8080

# Start Tomcat
CMD ["catalina.sh", "run"]
