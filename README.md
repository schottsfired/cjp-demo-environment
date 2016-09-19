# Docker Compose (v2) Demo Environment for CloudBees Jenkins Platform (CJP)

## Included Services

Nginx reverse proxy at http://cjp.local

CloudBees Jenkins Operations Center (CJOC) 2.7.19.1 at http://cjp.local/cjoc

CloudBees Jenkins Enterprise (CJE) 2.7.19.1 "test" at http://cjp.local/cje-test

CloudBees Jenkins Enterprise (CJE) 2.7.19.1 "prod" at http://cjp.local/cje-prod

Shared SSH Agent with Docker on Docker

Shared JNLP Cloud with Java Build Tools (OpenJDK 8, Firefox, Selenium, etc.) and Docker on Docker

## Prerequisites

built on [Docker for Mac Beta](https://blog.docker.com/2016/03/docker-for-mac-windows-beta/)
Docker on Docker support may not work for other configurations.

increase CPU/Memory limits in Docker preferences to as much as you can spare

open terminal and type:

    sudo vi /etc/hosts

add this entry:

    127.0.0.1 cjp.local

modify 'docker-compose.yml' 'volumes' under 'ssh-slave' to point to your host maven cache

## How to run

simply:

    docker-compose up

and wait a little while :)

## Pro tips

you can restart services with e.g.:

    docker-compose restart cje-test

see `` docker-compose.yml `` for list of available services

use ctrl+c to stop the environment, or better, use:

    docker-compose down

open an interactive terminal on a container (service) with:

    docker exec -it <serviceName> bash

or run a command on a container immediately, e.g. to ping another container:

    docker exec -it <serviceName> ping cjp.proxy

lastly, important directories like nginx logs, jenkins_home(s), etc. are volume mapped to the working project directory

## Post-startup tasks

### Connect Client Masters

go to http://cjp.local/cjoc

activate it

manage jenkins > configure system and set Jenkins URL to http://cjp.local/cjoc (or just _save_ the config if it's already correct)

add a client master item (cje-prod) with URL http://cjp.local/cje-prod

add a client master item (cje-test) with URL  http://cjp.local/cje-test

### Connect SSH Shared Agent

exec into the CJOC container and generate a key pair:

    docker exec -it cjoc bash

    ssh-keygen

Stick with the defaults and choose a password (or leave blank)

Then copy your public and private keys to a text editor:

    cd /var/jenkins_home/.ssh

    cat id_rsa

    cat id_rsa.pub

In CJOC, click "Credentials" and add your SSH private key

In `` docker-compose.yml `` add your public key to the 'command:' and restart the container:

    docker-compose restart ssh-slave

Create a Shared SSH Agent in CJOC with your new credentials, host: `` ssh-slave ``, and a Remote FS root of `` /home/jenkins ``

### Connect JNLP Shared Agent

add a shared cloud named e.g. 'shared-cloud' at the root of cjoc

update your `` post-boot.yml `` shared-cloud 'command:' with the on-screen instructions

start the jnlp slave (and watch it add itself to the shared-cloud):

    docker-compose start jnlp-slave

### Docker on Docker

Supported by SSH and JNLP slaves/agents, as well as on-master executors in cje-test

When using 'docker.build' or 'docker.image.inside' on these executors, containers will spawn from the host docker engine.
