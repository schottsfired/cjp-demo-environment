# Docker Compose (v2) Demo Environment for CloudBees Jenkins Platform (CJP)

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

    docker-compose restart proxy

see docker-compose.yml for list of available services

use ctrl+c to stop the environment

run commands on containers with:

    docker exec -it <containerId> bash

or:

    docker exec -it <containerId> ping cjp.local

lastly, note that data directories (nginx logs, jenkins_home(s)) are mapped to the working project directory

## Post-startup tasks

go to http://cjp.local

activate it

manage jenkins > configure system and set Jenkins URL to http://cjp.local/cjoc

add a client master item with URL  http://cjp.local/cje-test

add a shared cloud item named 'jnlp-shared-cloud' at the root of cjoc

start the jnlp shared agent (again):

    docker-compose start shared-agent

etc.
