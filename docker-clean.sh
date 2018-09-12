#!/bin/sh

xargs_option=
if [ "$(uname)" == "Linux" ]
then
    xargs_option="--no-run-if-empty"
fi

docker ps -a -q | xargs $xargs_option docker rm -v
docker images -f dangling=true -q | xargs $xargs_option docker rmi
docker volume ls -q | xargs $xargs_option docker volume rm
docker network ls | grep default | awk '{print $1}' | xargs $xargs_option docker network rm
