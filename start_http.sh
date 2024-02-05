#!/usr/bin/env bash

delete_container() {
    docker stop "$1"
    docker rm "$1"
}


DOCKER_REPO=medhy-dohou
DOCKER_APP_NETWORK=app-network

DOCKER_HTTP_IMAGE=http
DOCKER_HTTP_IMAGE_FQDN=${DOCKER_REPO}/${DOCKER_HTTP_IMAGE} 

DOCKER_HTTP_CONTAINER_NAME=http

if ! docker > /dev/null 2>&1 ; then
    echo "Docker command not found, ensure it is installed and that you have the rights to access docker daemon"
    exit 1
fi

docker build --no-cache -t $DOCKER_HTTP_IMAGE_FQDN -f Dockerfile.http .

if docker container inspect ${DOCKER_HTTP_CONTAINER_NAME} > /dev/null 2>&1; then delete_container "${DOCKER_HTTP_CONTAINER_NAME}"; fi

docker run -dit --name ${DOCKER_HTTP_CONTAINER_NAME} --network ${DOCKER_APP_NETWORK} -p 8000:80 $DOCKER_HTTP_IMAGE_FQDN