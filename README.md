# Docker Compose (v2) Demo Environment for CloudBees Jenkins Platform (CJP)

## Prerequisites
docker version 1.12.0-rc3-beta18 (build: 9996) or above

increase limits in Docker preferences (CPU: 3, Memory: 6GB)

open terminal and type

    sudo vi /etc/hosts

add this entry:

    127.0.0.1 cjp.local

## How to run
simply,

    docker-compose up

you can restart services with e.g.:

    docker-compose restart proxy

see docker-compose.yml for list of services

use ctrl+c to stop the environment

run commands on containers with

    docker exec -it <containerId> bash

or

    docker exec -it <containerId> ping cjp.local

lastly, note data directories (nginx logs, jenkins_home(s)) are mapped to the working project directory

## Post-startup
go to http://cjp.local

activate it

manage jenkins > configure system

set Jenkins URL to http://cjp.local/cjoc

add client master http://cjp.local/cje-test

upgrade plugins (consider mock security realm)

enable security/SSO
