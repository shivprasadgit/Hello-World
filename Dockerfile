FROM tomcat:8.5.51-jre8-alpine
MAINTAINER shivprasad
RUN rm -rf /usr/local/tomcat/webapps/*
COPY ./target/*.war /usr/local/tomcat/webapps/hello-app.war
CMD ["catalina.sh","run"]
