#!/bin/bash

delete_container() {
    docker stop "$1"
    docker rm "$1"
}

# General variables
DOCKER_REPO=medhy-dohou
DOCKER_NETWORK_NAME=app-network
DOCKER_CONTAINER_NAME_POSTGRES=postgres
DOCKER_CONTAINER_NAME_ADMINER=adminer
DOCKER_DATA_FOLDER=/tmp/tp-devops/medhy-dohou

# Postgresql containers variables
DOCKER_POSTGRES_IMAGE_NAME=postgres
POSTGRES_DB=db
POSTGRES_USER=usr
POSTGRES_PASSWORD=pwd

# Adminer variables
DOCKER_IMAGE_ADMINER=adminer:latest


if ! docker > /dev/null 2>&1 ; then
    echo "Docker command not found, ensure it is installed and that you have the rights to access docker daemon"
    exit 1
fi

docker build -t ${DOCKER_REPO}/${DOCKER_POSTGRES_IMAGE_NAME} -f ./Dockerfile.db . > /dev/null

if ! docker network inspect ${DOCKER_NETWORK_NAME} > /dev/null 2>&1; then
    docker network create ${DOCKER_NETWORK_NAME} > /dev/null || (echo "Cannot create private network, check logs" && exit 1)
fi
if docker container inspect ${DOCKER_CONTAINER_NAME_ADMINER} > /dev/null 2>&1; then delete_container "${DOCKER_CONTAINER_NAME_ADMINER}"; fi

docker run -d --name ${DOCKER_CONTAINER_NAME_ADMINER} --network ${DOCKER_NETWORK_NAME} -p 8080:8080 ${DOCKER_IMAGE_ADMINER}

if docker container inspect ${DOCKER_CONTAINER_NAME_POSTGRES} > /dev/null 2>&1; then delete_container "${DOCKER_CONTAINER_NAME_POSTGRES}"; fi

docker run -d --name ${DOCKER_CONTAINER_NAME_POSTGRES} \
            -v ${DOCKER_DATA_FOLDER}/postgres:/var/lib/data/postgres \
            -e POSTGRES_DB=${POSTGRES_DB} \
            -e POSTGRES_USER=${POSTGRES_USER} \
            -e POSTGRES_PASSWORD=${POSTGRES_PASSWORD} \
            --network ${DOCKER_NETWORK_NAME} ${DOCKER_REPO}/${DOCKER_POSTGRES_IMAGE_NAME}