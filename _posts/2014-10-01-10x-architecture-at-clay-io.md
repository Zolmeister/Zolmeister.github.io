---
layout: post
title:  "10x: Architecture at Clay.io"
date:   2014-10-01
---


![Clay.io](/assets/images/clay-architecture-1.png)

This is the first post in my new series `10x`, where I share my experiences
and how we do things at [Clay.io](http://clay.io/) to develop at scale with a small team.
If you find these things interesting, we're hiring - [zoli@clay.io](mailto:zoli@clay.io) .

Update:

  - [10x: Logging at Clay.io](http://zolmeister.com/2014/10/10x-logging-at-clay-io.html)

## The Cloud

#### CloudFlare

[![CloudFlare](/assets/images/cloudflare-logo.png)](https://www.cloudflare.com/)

[CloudFlare](https://www.cloudflare.com/) handles all of our DNS, and acts as a distributed caching
proxy with some additional DDOS protection features. It also handles SSL.


#### Amazon EC2 + VPC + NAT server

[![Amazon Web Services](/assets/images/aws-logo.png)](http://aws.amazon.com/)

Almost all of our servers live on Amazon EC2, most are either medium or large instances.
We also use Amazon VPC to host some of our servers inside of a private network,
inaccessible from the outside world. In order to get into this private network we have
a NAT server, which also serves as our VPN endpoint which we use when working
with our internal network. ([guide](http://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_Scenario2.html), [OpenVPN](https://openvpn.net/index.php/open-source/documentation/howto.html))


#### Amazon S3

We use Amazon S3 as our CDN backend, which hosts all of our static content.
We use a separate domain for this: `cdn.wtf` for security and performance
reasons (cookie-less domain).


#### HAProxy

[HAProxy](http://www.haproxy.org/) is an extremely performant reverse-proxy which we use to route traffic to
our different services. This work is non-trivial due to the nature of Clay.io and its
platform support concerns (and legacy code support), which I will go into detail in a later article.

We currently have a single HAProxy server on an m3.medium instance, but will upgrade as traffic increases.
In addition, we may add Amazon ELB in front to scale horizontally if necessary.

#### App Server - Docker

[![Docker](/assets/images/docker-logo.png)](https://www.docker.com/)

[Docker](https://www.docker.com/) is tool to manage Linux containers, which are similar to Virtual Machines
except with less overhead (and without some isolation and security guarantees).
The key to Docker is that code shipped inside of a container should run the same
no matter what the host machine looks like.

We currently run most of our computational services on an `app server` via Docker.
This server can easily be replicated to meet elastic demand, and services can be moved on and off easily.
Eventually we hope to manage these app servers with a tool like Kubernetes. (See bottom of post)

#### Staging App Server - Docker

Our staging environment server is identical to our application server, and
runs the exact same docker binaries that we run in production. This environment
has been critical to preventing unnecessary breakage and downtime of our production systems.

## Data

#### MySQL

[![MySQL](/assets/images/mysql-logo.jpg)](http://www.mysql.com/)

[MySQL](http://www.mysql.com/) is a production-hardened relational SQL database.
The vast majority of our data currently resides inside a Master-Slave MySQL cluster.
We have one master, and two slave servers which serve most of our queries for our users.
Eventually we may have to move tables or shard the single master server, but hopefully not for a while.

#### Logstash

[![logstash](/assets/images/logstash-logo.png)](http://logstash.net/)

[Logstash](http://logstash.net/) is a log aggregation tool, with Kibana integration for analysis.
It basically handles all of our application logs, and gives us a place to check
for errors when something goes wrong. It saves us from having to SSH into a machine to check logs.

#### MongoDB

[![MongoDB](/assets/images/mongoDB-logo.png)](http://www.mongodb.org/)

[MongoDB](http://www.mongodb.org/) is a NoSQL document storage database.
We currently use mongodb for some of our developer endpoints, and for our A/B testing
framework [Flak Cannon](https://github.com/claydotio/flak-cannon).

#### Memcached

[Memcached](http://memcached.org/) is a key-value store, used mostly for caching. In many ways it is similar to Redis.
We currently use Memcached in our legacy webapp for caching MySQL query results.
Eventually we would like to replace this with Redis.

## DevOps

#### Ansible

[![Ansible](/assets/images/ansible-logo.png)](http://www.ansible.com/home)

[Ansible](http://www.ansible.com/home) has been our tool of choice for managing our servers. It's simple enough for most developers to learn quickly
and be comfortable working with, and has been critical for automating many of the processes normally
managed by an operations team.

## Other Services

#### GitHub

[GitHub](https://github.com/) - Great source code management, enough said.

#### Uptime Robot

[Uptime Robot](https://uptimerobot.com/) is a **free** monitoring service which we use to monitor our healthchecks and endpoints.
If anything goes down, it will email and text message us within 5min.

#### Drone.io

[Drone.io](https://drone.io/) is a continuous integration service, which we use to continuously run our
test suites for our various projects. It is similar to TravisCI, and has recently
released an open source self-hostable version.

#### Docker Registry

We currently use the official [Docker registry](https://registry.hub.docker.com/) to manage our docker containers.
It's similar to GitHub, except for Docker containers.

#### New Relic

[New Relic](http://newrelic.com/) is a server and application monitoring service, which we mostly use to
monitor our servers to let us know when a machine is running out of disk or memory

#### Google Analytics

[Google Analytics](http://www.google.com/analytics/) is our main website analytics tracking tool.
For tracking our site specific features, we use the custom events features.

#### Google Apps

[Google Apps](http://www.google.com/enterprise/apps/business/) provides email for our domain clay.io, and gives our organization a shared
Google Drive setup.

#### Last Pass

[Last Pass](https://lastpass.com/) is a password management service which allows us to share company
credentials for all of the other above services easily amongst the team.

## The Future

While we are currently happy with our setup today, we hope to improve it in the coming months.
This initial infrastructure version is missing some features which weren't necessary enough
to justify spending time on, but we will eventually need to come back to them as we scale.

[Kubernetes](https://github.com/GoogleCloudPlatform/kubernetes) is looking to be an amazing project and tool for managing Docker containers at scale.
We will be following it's development closely and hopefully put it into production as the project matures.

[Amazon Glacier](http://aws.amazon.com/glacier/) is another technology we have been looking at for doing database backups,
and hope to implement that in the near future.

[RethinkDB](http://rethinkdb.com/), while quite immature, is also quite an interesting project. We will definitely be following it's
progress and may eventually move some of our data into it as we move away from MySQL.
