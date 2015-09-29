---
layout: post
title:  "CharityVid - Server Configuration"
date:   2013-05-29
---

![](http://1.bp.blogspot.com/-nFJjOIwV1bM/UWscXbfPO1I/AAAAAAAAAcA/RRgsCCYqYKU/s1600/logo.png)
In this post, I will focus on how I run and update the&nbsp;CharityVid.org&nbsp;servers, using the following tools:

*   [Up](https://github.com/LearnBoost/up) &nbsp;- live reload tool
*   [nginx](http://nginx.org/)&nbsp;(pronounced Engine X)
*   [fabric](http://docs.fabfile.org/en/1.6/)

Lets start with Up. Up allows us to do live reloads of the site, while&nbsp;simultaneously&nbsp;load balancing across many&nbsp;processes. This makes it quite robust and keeps the server from going down. If one thread fails, another will just take over, no problem. Here is how I launch it:

```
     up -w app.js -p 3100 -n 2 -k -T charityvid
```
CharityVid runs on [express.js](http://expressjs.com/), however unlike a normal express application we do not start the server ourselves. Instead we let Up handle it:

```js
     var app = express()
     ...
     app.configure('production', function() {
       module.exports = http.Server(app)
     })
```
Now after launching, Up will watch (-w) app.js for changes, listen on port (-p) 3100, with 2 (-n) threads, &nbsp;spawn new workers on death (-k), and have a title (-T) of charityvid for the process view. If we want to issue the reload command, then we call:

```
kill -s SIGUSR2 $(cat /var/run/charityvid.pid)
```
At this point, we have our server running on port 3100, now we need to expose it to the outside world on port 80.&nbsp;To do this, we will use nginx, which will also provide caching support by sitting between our express server and the internet. Here is what a basic nginx config file looks like:

```
     worker_processes 1;
     error_log logs/error.log;
     pid    logs/nginx.pid;
     events {
       worker_connections 1024;
     }
     http {
       include    mime.types;
       default_type application/octet-stream;
       sendfile    on;
       keepalive_timeout 65;
       gzip on;
     #charityvid.org
       server {
         listen    80;
         server_name charityvid.org www.charityvid.org;
         location / {
           proxy_set_header Host $http_host;
           proxy_http_version 1.1;
           proxy_set_header Upgrade $http_upgrade;
           proxy_set_header Connection "upgrade";
           proxy_pass  http://127.0.0.1:3100;
         }
       }
     }
```
If you installed from source, start nginx by calling:

```
/usr/local/nginx/sbin/./nginx
```
Now we have our nginx acting as a proxy between port 3100 and port 80, for the charityvid hostnames. This is also useful because if we wanted to run multiple apps on one IP (which I do), you can have them all on port 80 but listening for different hostnames (effectively URLs).

Finally, we want to automate the deployment process. This is what fabric is for. With fabric we can issue commands to our remote server using python. A basic config looks like this:

```
     from __future__ import with_statement
     from fabric.api import *
     def ec2():
       env.user='ubuntu'
       env.hosts=['ubuntu@123.123.123.123']
     def update(app):
       with cd('/home/'+env.user+'/websites'):
         if app=="charityvid":
           run('cd charityvid && git pull')
           sudo('kill -s SIGUSR2 $(cat /var/run/charityvid.pid)')
     def nginx():
       sudo('/usr/local/nginx/sbin/./nginx')
     def init():
       start('charityvid')
```
We can then issue the update command like so:

```
fab ec2 update:charityvid
```

This will pull from the git repo (prod branch), and then send the command to Up to update. For more information on the automation used here, reference my blog post on [Upstart](http://www.zolmeister.com/2012/12/how-to-deploy-nodejs-applications.html), which outlines how we can use [upstart](http://upstart.ubuntu.com/)&nbsp;to daemonize our server process without using screen (or byobu).
