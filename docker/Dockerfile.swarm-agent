# Image installs with latest Java 8 OpenJDK on Alpine Linux
FROM openjdk:8-jdk-alpine

USER root

# Update and upgrade apk then install curl, maven, git, and nodejs
RUN apk update && \
	apk upgrade && \
	apk --no-cache add curl && \
	apk --no-cache add maven && \
	apk --no-cache add git && \
	apk --no-cache add nodejs

# Download and install docker
RUN curl -L -o /tmp/docker-latest.tgz https://get.docker.com/builds/Linux/x86_64/docker-latest.tgz && \
	tar xzf /tmp/docker-latest.tgz -C /tmp/ && \
	mv /tmp/docker/* /usr/bin/ && \
	chmod a+x /usr/bin/docker* && \
	rm -rf /tmp/docker*

# Create user groups and users
RUN addgroup -g 50 docker && \
	addgroup staff && \
	adduser -S jenkins && \
	adduser jenkins docker && \
	adduser root docker

# Create workspace directory to build in
RUN mkdir /workspace && \
	chmod 777 /workspace

# Download the latest Jenkins swarm client with curl - version 3.3
# Browse all versions here: https://repo.jenkins-ci.org/releases/org/jenkins-ci/plugins/swarm-client/
RUN curl -O https://repo.jenkins-ci.org/releases/org/jenkins-ci/plugins/swarm-client/3.3/swarm-client-3.3.jar 
