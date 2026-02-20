#FROM openjdk:13-jdk-alpine
FROM eclipse-temurin:21-jdk

ARG UID

RUN echo "jenkins:x:${UID}:100:guest:/home/jenkins:/sbin/nologin" >> /etc/passwd && \
    mkdir /home/jenkins && chmod 777 /home/jenkins && \ 
    apt -y update && apt -y upgrade && \
    apt -y install git openssh-server zip unzip r-base-core bash curl python3-pip python3-venv

