#FROM openjdk:13-jdk-alpine
FROM eclipse-temurin:21-jdk-alpine 

RUN echo "jenkins:x:2030:100:guest:/home/jenkins:/sbin/nologin" >> /etc/passwd && \
    mkdir /home/jenkins && chmod 777 /home/jenkins && \ 
    apk update && \
    apk add git openssh zip R bash curl python3 py3-pip

