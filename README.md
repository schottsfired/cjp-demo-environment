# Docker Compose (v2) Demo Environment for CloudBees Jenkins Platform (CJP)

## Included Services

Nginx reverse proxy at http://cjp.local

CloudBees Jenkins Operations Center (CJOC) v16.06 at http://cjp.local/cjoc

CloudBees Jenkins Enterprise (CJE) v16.06 "test" at http://cjp.local/cje-test

CloudBees Jenkins Enterprise (CJE) v16.06 "prod" at http://cjp.local/cje-prod

Shared SSH Agent

Shared JNLP Cloud with Java Build Tools (OpenJDK 8, Firefox, Selenium, etc.)

## Prerequisites

built on [Docker for Mac Beta](https://blog.docker.com/2016/03/docker-for-mac-windows-beta/)

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

### Connect JNLP Shared Agent

add a shared cloud named e.g. 'jnlp-shared-cloud' at the root of cjoc

update your `` docker-compose.yml `` shared-cloud 'command:' with the on-screen instructions

start the jnlp shared agent:

    docker-compose start shared-agent-jnlp

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

    docker-compose restart shared-agent-ssh

Create a Shared SSH Agent in CJOC with your new credentials, host: `` shared-agent-ssh ``, and a Remote FS root of `` /home/jenkins ``

## TODO

use new Docker preferences pane item to move away from cjp.local

bootstrap a seed job that loads "golden" jobs from any GH repo

get JNLP/SSH shared agent 'command:' out of docker-compose
