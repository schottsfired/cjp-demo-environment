FROM cloudbees/jnlp-slave-with-java-build-tools:latest

#add Docker
USER root
RUN curl -L -o /tmp/docker-latest.tgz https://get.docker.com/builds/Linux/x86_64/docker-latest.tgz \
  && tar xzf /tmp/docker-latest.tgz -C /tmp/ \
  && mv /tmp/docker/* /usr/bin/ \
  && chmod a+x /usr/bin/docker* \
  && rm -rf /tmp/docker* \
  && delgroup staff \
  && groupadd -g 50 docker \
  && groupadd staff \
  && adduser jenkins docker \
  && adduser root docker

USER jenkins
