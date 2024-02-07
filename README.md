# <center>TP DevOps - S8 - DOHOU Medhy - Promo 2025</center>

## Day 1 - Docker
## Database

### Why should we run the container with a flag -e to give the environment variables?

We should use the `-e` flag to ensure that our container images are as generic as possible, instead of hardcoding them directly into the image. It is possible to override environment variables using this flag, but say the user might not read the doc, they might encounter behaviour they're unfamiliar with. It also ensure that the credentials are not exposed through the VCS.

### Why do we need a volume to be attached to our postgres container?

A volume is a piece of disk space that is shared between a container and it's host. A container is a stateless machine by default, meaning that it does not persist data in its filesystem after a reboot. Providing a volume (or a database connection, an S3 connect... by externalizing the stateful part of the app), we mount in our containers' filesystem a persistence point for it to store data indefinitely.

### Document your database container essentials: commands and Dockerfile.

There's 2 scripts at the root of this repository : 

- `prepare_data_folder.sh` : This ones create a temporary directory to store the data of the postgres database
- `start_databases.sh` : This script checks the existence of the docker command : if it doesn't exists, the user is prompted to install docker on the machine. Otherwise, it builds the postgres image (with our custom SQL initialization scripts embedded, from `dockerfiles/configs/db`). Then it checks the existence of our docker private network, if it doesn't exists, it creates it. Once that's out of the way, the scripts checks for the exitence of the containers for postgres and adminer, if they exist, we destroy them to start fresh. Then both containers are created. There's a bunch of environment variables that can be overloaded.

#### Overloading the `start_databases.sh` defaults
- `POSTGRES_DB` : The name of the initial database created when the postgres container starts. Defaults to `db`.
- `POSTGRES_USER` : The name of the initial user. Defaults to `usr`
- `POSTGRES_PASSWORD` : The password of the initial user. Defaults to `pwd`.


## Backend API

### Why do we need a multistage build? And explain each step of this dockerfile.

We need multistage build to ship a minimal size image while also ensuring the build environment is the same for every environment we might want to deploy our images to. At the same time, by using two different stages (one for build, one for runtime), we can ensure that we only have the bare minimum needed to run our application. It could also be argued that it reduces the attack surface of the container by embedding less possible CVE sources.

Now for the explaination : 

```dockerfile

# We pull the maven base image from docker hub, from which we create a stage
# We also give it an alias of build so as to easily copy the produced files after this stage is done
FROM maven:3.9.6-sapmachine-21 AS build
# We create an environment variable in the container building context
ENV MYAPP_HOME /opt/app

# The workdir directive allows us to change the current working directory during image build, as well as set the working directory for the image entrypoint
WORKDIR ${MYAPP_HOME}
# We copy the content of the backend-api source folder to the current working directory (note: this is subobtimal)
COPY backend-api ${MYAPP_HOME} 

# Finally for this stage, we run this command, that allows maven to produce us an executable jar file. Note that we skip tests, as the testing phase isn't our responsibility
RUN mvn package -DskipTests

# We move on to the "run" stage, our container will ultimately run off of this base image
FROM eclipse-temurin:21-jre-alpine

# Same as the build stage
ENV MYAPP_HOME /opt/app
WORKDIR $MYAPP_HOME
# We copy the produced jar files from the build stage over to our run stage
COPY --from=build $MYAPP_HOME/target/*.jar $MYAPP_HOME/api.jar

# Finally, we use this java command that executes our produced jar as the entrypoint of our container
ENTRYPOINT java -jar api.jar

```

## HTTP Server (Apache httpd)

### Why do we need a reverse proxy?

We use a reverse proxy as an entrypoint to our infrastructure from the outside world. By using a reverse proxy, we can expose selected server, ports & services as we please. Not only does this increase security, but we can also have different features like route binding (binding an app to <url>/app-1 and another one to <url>/app-2, for example), we can also do load-balancing, ip filtering, add or modify http-headers. These are only a couple possibilities with a reverse proxy. 

In our case, much like a company, we are trying to expose services available on our docker private network to our public net (in our case, localhost).

## Docker compose

### Why is docker-compose so important?

Because it allows us to describe the environment in a comprehensive way, rather than having a script for each service we'd like to up/down/restart. It is a descriptive way to describe containers, networks, and objects present in the infrastructure.

### Document docker-compose most important commands.

- `docker compose up [service name in compose file]`, is used to deploy containers of your current working directorys' `docker-compose.yml` file on the local machine. It spawns the container, adds the networks and objects, such as volumes, necessary for everything to work together. This command eventually takes a service name to bring up.
- `docker compose down [service name in compose file]` is the opposite of the previous command, as it is used to destroy services containers currently running on the host. 
- `docker compose logs` can be used to view the recent logs of the services.

### Document your `docker-compose.yml`


```yml
version: '3.7'

services:
    # Our backend service descriptor
    backend:
        # We tell our compose file where to find our Dockerfile for this service
        build:
          dockerfile: Dockerfile.api
        networks:
          - app-network
        # To start, our backend needs the database service to exist
        depends_on:
          - database

    database:
        build:
          dockerfile: Dockerfile.db
        networks:
          - app-network
        # We attach our postgres directory as a volume of this services' container (for data persistence)
        volumes:
          - /tmp/tp-devops/medhy-dohou/postgres:/var/lib/data/postgres
        # We describe here our environment variable in this services' container
        environment:
          POSTGRES_USER: usr
          POSTGRES_DB: db
          POSTGRES_PASSWORD: pwd

    httpd:
        build:
          dockerfile: Dockerfile.http
        # We describe here, the ports exposed on our host from this container
        ports:
          - 80:80
        networks:
          - app-network
        depends_on:
          - backend

# We declare our app-network here
networks:
    app-network:
```

## Day 2 - Github Actions

## Setup GitHub Actions

### Unit tests? Component tests?

Unit tests are meant to test small parts of a class logic, such as a function, or a constructor.

Component tests (or integrations test), are for testing the logic of the application itself, so it can test more functions and multiple classes and how they interact with each others.

### What are testcontainers ?

Testcontainers is a library that leverages the docker software to spawn databases/external services dynamically, for testing purposes. This way, we can test our code without mocking these external srevices, allowing us to test integration in a real life scenario.

## Day 3 - Ansible

## Introduction