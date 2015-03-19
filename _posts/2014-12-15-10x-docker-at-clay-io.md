---
layout: post
title:  "10x: Docker at Clay.io"
date:   2014-12-15
---


![docker logo](/assets/images/docker_logo.png)

## Intro

At [Clay](http://clay.io/), our deploy process is fun. Seriously. Because we use Docker.

Docker is a containerization tool that allows for easy application isolation and deployment.
The basic idea is that Docker runs your application in a virtualized isolated environment,
similar to a virtual machine, but without the overhead. You start with a 'base image',
and then describe how to create a 'container' using a Dockerfile.

## Overview

![docker diagram](/assets/images/docker-diagram.png)

#### Update: [Example Ansible Config](https://gist.github.com/Zolmeister/aa0cf06678170a39c3c0) (may not follow best practices)

Our deploy process looks like this:

  - Merge all code to be shipped into git `master` branch
  - `git tag` for release (eg. v1.0.0)
  - Build docker image (code lock)
  - `docker tag` for release (eg. v1.0.0)
  - Push docker image to the registry
  - Update staging cluster container versions (zero downtime)
    - Make sure backup container is running
    - Upgrade master container
    - Wait for new master to be up
    - Upgrade backup container
  - Update production cluster container versions (zero downtime)
    - (see above process)

This process guarantees that we are running the exact same code in staging and production,
and allows us to roll back to the last docker container release version if anything goes wrong.

## Clay.io Dockerfiles

Here is an example Dockerfile from our mobile app ([source](https://github.com/claydotio/clay-mobile/blob/master/Dockerfile)):

```docker
FROM dockerfile/nodejs:latest

# Install Git
RUN apt-get install -y git

# Add source
ADD ./node_modules /opt/clay-mobile/node_modules
ADD . /opt/clay-mobile

WORKDIR /opt/clay-mobile

# Install app deps
RUN npm install

CMD ["npm", "start"]
```

The file is self-explanatory. It simply copies the source code from the current directory into the container.
Environment variables will be used to introduce sensitive / dynamic configuration.
One important note is that `npm start` actually compiles and minifies the code for production:

```js
// package.json
{
  "scripts": {
    "build": "node_modules/gulp/bin/gulp.js build"
    "start": "npm run build &&
              ./node_modules/pm2/bin/pm2 start ./bin/server.coffee
                -i max
                --name clay_mobile
                --no-daemon
                -o /var/log/clay/clay_mobile.log
                -e /var/log/clay/clay_mobile.error.log",
  }
}
```

This is because we need to re-build the static files with the production environment variables.
For more examples, checkout our GitHub: [github.com/clay.io](https://github.com/claydotio)

## Basic Deployment of A Docker Image

At Clay, we host our images on the [docker registry](https://registry.hub.docker.com/repos/clay/).

Because of Docker, deploying our applications to staging and production environments is trivial.
This is the entire process (untagged container, to staging - automated with [Ansible](http://www.ansible.com/home)):

```bash
# Local machine / Build server
docker build -t clay/mobile .
docker push clay/mobile
```

```bash
# Staging / Production server
docker pull clay/mobile
docker run
    --restart on-failure
    -v /var/log/clay:/var/log/clay
    -p 50000:3000
    -e CLAY_MOBILE_HOST=XXXX
    -e CLAY_API_URL=XXXX
    -e FC_API_URL=XXXX
    -e NODE_ENV=production
    -e PORT=3000
    --name mobile
    -d
    -t clay/mobile:VERSION
```

(Note: Ports 49,152 - 65,535 are generally used for private applications)

## Zero-Downtime Updates

If you noticed in the above start script, we use [PM2](https://github.com/Unitech/pm2) to handle clustering multiple server processes.
PM2 supports zero-downtime code updates, however because it is inside the container and we never change code within a container at runtime, we don't use it.
PM2 is used simply to take advantage of multiple server cores.

The key to zero-downtime updates is to run two server processes. A master process, and a backup process.
We do this by assigning different ports to two container deployments:

```bash
docker run ... -e PORT=50000 --name mobile
docker run ... -e PORT=50001 --name mobile-backup
```

[HAProxy](http://www.haproxy.org/) handles re-routing traffic to the backup server when the master goes down:

```
# example haproxy.cfg

backend mobile
  mode http
  balance roundrobin
  server app1 x.x.x.x:50000 check
  server app1b x.x.x.x:50001 check backup
  server app2 x.x.x.x:50000 check
  server app2b x.x.x.x:50001 check backup
```

A future post on HAProxy will go into more details on how we use HAProxy to load balance across our servers.

The following deploy process is fully automated by Ansible:

  1. Verify backup healthy container status (Ansible)
  1. `docker pull clay/mobile:v1.0.0`
  1. Kill master container (network requests re-route automatically to the backup)
    - `docker rm -f mobile`
  1. Update master container, and restart
    - `docker run ...`
  1. Once the master container comes back up, network requests will move back to the master
  1. Kill and update the backup container
    - `docker rm -f mobile-backup && docker run ...`

If anything goes wrong, simply revert to an older image version:  
`docker run -t clay/mobile:v0.0.12`.


## Closing

If you missed previous `10x` posts:

  - [Architecture](http://zolmeister.com/2014/10/10x-architecture-at-clay-io.html)
  - [Logging](http://zolmeister.com/2014/10/10x-logging-at-clay-io.html)

Also, we're hiring - [zoli@clay.io](mailto:zoli@clay.io)
