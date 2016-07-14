# Docker Compose (v2) Demo Environment for CloudBees Jenkins Platform (CJP)

## Included Services

Nginx reverse proxy at http://cjp.local

CloudBees Jenkins Operations Center (CJOC) at http://cjp.local/cjoc

CloudBees Jenkins Enterprise (CJE) "test" Environment at http://cjp.local/cje-test

CloudBees Jenkins Enterprise (CJE) "prod" Environment at http://cjp.local/cje-prod

SSH Shared Agent at ssh-shared-agent:4444

JNLP Shared Agent connected manually (would be automated in real world)

## Prerequisites

built on Docker for OSX 1.12.0-rc3-beta18 (build: 9996)

boot2docker/docker-machine v1.12.0-rc3 should also work

increase limits in Docker preferences (CPU: 3, Memory: 6GB)

open terminal and type:

    sudo vi /etc/hosts

add this entry:

    127.0.0.1 cjp.local

## How to run

simply:

    docker-compose up

and wait a little while :)

## Pro tips

you can restart services with e.g.:

    docker-compose restart shared-agent

see docker-compose.yml for list of available services

use ctrl+c to stop the environment

and don't forget to use:

    docker-compose down

for a "hard" reset when e.g. networking changes.

run commands on containers with:

    docker exec -it <containerId> bash

or:

    docker exec -it <containerId> ping cjp.local

lastly, note that data directories (nginx logs, jenkins_home(s)) are mapped to the working project directory

## Post-startup tasks

### Connect Client Masters

go to http://cjp.local/cjoc

activate it

manage jenkins > configure system and set Jenkins URL to http://cjp.local/cjoc

add a client master item (cje-prod) with URL http://cjp.local/cje-prod

add a client master item (cje-test) with URL  http://cjp.local/cje-test

### Connect JNLP Shared Agent

add a shared cloud item named 'jnlp-shared-cloud' at the root of cjoc

update your docker-compose.yml shared-cloud 'command:' accordingly

start the jnlp shared agent (again):

    docker-compose start shared-agent

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

In docker-compose.yml add your public key to the 'command:' and restart the container:

    docker-compose restart shared-agent-ssh

Create a new shared agent in CJOC with your new credentials, host 'shared-agent-ssh', and a Remote FS root of /home/jenkins

## TODO

bootstrap seed job that loads "golden" jobs from any GH repo

get JNLP/SSH shared agent 'command:' out of docker-compose
