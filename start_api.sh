#!/usr/bin/env bash

delete_container() {
    docker stop "$1"
    docker rm "$1"
}

DOCKER_REPO=medhy-dohou
DOCKER_APP_NETWORK=app-network

DOCKER_BACKEND_IMAGE=backend
DOCKER_BACKEND_IMAGE_FQDN=${DOCKER_REPO}/${DOCKER_BACKEND_IMAGE} 
DOCKER_BACKEND_CONTAINER_PORT=8084

DOCKER_BACKEND_CONTAINER_NAME=backend

if ! docker > /dev/null 2>&1 ; then
    echo "Docker command not found, ensure it is installed and that you have the rights to access docker daemon"
    exit 1
fi

docker build --no-cache -t ${DOCKER_BACKEND_IMAGE_FQDN} -f ./Dockerfile.api . > /dev/null

if docker container inspect ${DOCKER_BACKEND_CONTAINER_NAME} > /dev/null 2>&1; then delete_container ${DOCKER_BACKEND_CONTAINER_NAME}; fi

docker run --name ${DOCKER_BACKEND_CONTAINER_NAME} \
            --network $DOCKER_APP_NETWORK \
            ${DOCKER_BACKEND_IMAGE_FQDN}