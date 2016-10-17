#!/bin/sh

docker ps -a -q | xargs docker rm -v
docker images -f dangling=true -q | xargs docker rmi
docker volume ls -q | xargs docker volume rm
docker network ls | grep default | awk '{print $1}' | xargs docker network rm
