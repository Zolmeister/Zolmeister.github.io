---
layout: post
title:  "CharityVid - Prepping for scale"
date:   2013-05-21
---

![](http://1.bp.blogspot.com/-nFJjOIwV1bM/UWscXbfPO1I/AAAAAAAAAcA/RRgsCCYqYKU/s1600/logo.png)
In this post, I will outline how I setup horizontal scaling on [AWS EC2](http://aws.amazon.com/ec2/?_encoding=UTF8&camp=1789&creative=9325&linkCode=ur2&tag=zolmeister-20)![](http://www.assoc-amazon.com/e/ir?t=zolmeister-20&l=ur2&o=1), and also how I added server monitoring tools to watch my servers. I will go over:

*   Migrating to [Mongolab](https://mongolab.com/)
*   [AWS Load Balancer](http://docs.aws.amazon.com/elasticbeanstalk/latest/dg/using-features.managing.elb.html) setup
*   [Loggly](http://loggly.com/) logging
*   [New Relic](http://newrelic.com/) server monitoring
*   [Pingdom](https://www.pingdom.com/) uptime monitor
*   [nodefly](http://nodefly.com/) node.js monitor

The AWS Load balancer allow you to distribute load coming to a url to different servers. It does this by creating a dynamic DNS entry, which resolves to the server IP which has the least load and thus is best suited to handle traffic. To setup the AWS load balancer is quite simple, and it even removes the need to host your SSL certificate on the webservers themselves. Instead you can have the balancer server the SSL certificate, and then forward the SSL traffic over to port 80 on your servers. This is secure because we assume an uncompromised local network (and indeed Amazon's internal AWS network isolates instances networks properly).

The first step to load balancing is to create an [AMI](http://aws.amazon.com/about-aws/whats-new/2013/03/12/announcing-ami-copy-for-amazon-ec2/) (hard disk clone) of your main server. From there, you can spin up multiple cloned instances based on that AMI. These clones can then be brought online, and then added to the load balancer.

Next, is the creation of the load balancer. It's quite a simple setup, the key being that you DNS is setup properly. For me, I found it easiest to move my DNS to [cloudflare](https://www.cloudflare.com/) (which has given me other security benefits as well), and then all you do is create a CNAME record for your domain which points to the dynamic DNS of the load balancer.

Now, if a server goes down for some reason, the load balancer will automatically stop sending it traffic. It also distributes the load so that you can handle a lot more traffic.

There is a problem however, because our MongoDB instance which has all of our users is on each server independently, but we want all the servers to read from the same database. Normally, a master database server would be used, but I found it quicker and easier to use the hosted service Mongolab. With mongolab, we create a database with their interface, and then upload our existing database to the server.

```
     mongodump --dbpath /data/db/ --out dump
     mongorestore -h xxx.mongolab.com:xxxx -d charityvid-database -d -u <user> -p <password> dump
```
In addition to creating a production shared mongodb instance, I also created a dev clone of the database for testing purposes.

The next step is to set up services which will alert us when the service goes down, and will log error events so that we can debug issues later. For basic uptime monitoring we use Pingdom, which just pings the site every once in a while and will email us (or alert us through their android app) that the site has gone offline.

Next we setup New Relic to monitor the whole server. New Relic sets up a daemon which reports things like CPU and RAM usage, as well as network usage so that you can make sure that the server is running smoothly (and also you get a [free t-shirt](http://newrelic.com/nerdlife)).

In addition to full server monitoring, I also use nodefly to monitor the main node.js server process which tracks response time, the event loop, and heap size. This is useful is we ever encounter any response time issues, or any other node.js specific issue which is not readily visible through New Relic. That being said, because I run more that one service on my server I mostly pay attention to New Relic, and only occasionally look at nodefly to make sure response times are low.

Finally, and most importantly, we need to log error events. For this we will use the Loggly service, and the nodejs [winston](https://github.com/flatiron/winston) library. For logging, I set up my own log.js file which manages the winston setup and the configuration settings with the [winston-loggly](https://github.com/indexzero/winston-loggly) plugin. It then exports the winston object so that I can import it in other modules for when I want to log things. My log.js config looks like this:

```js
   var winston = require('winston'),
       Loggly = require('winston-loggly').Loggly,
       settings = require('./settings')
     winston.add(winston.transports.File, { filename: 'charityvid.log' });
     if(!settings.DEBUG){
       winston.add(Loggly, {
         subdomain: 'charityvid',
         inputToken: settings.LOGGLY_KEY
       })
     }
     //winston.remove(winston.transports.Console);
     module.exports = winston
```
In order to determine what level to log things at, I generally follow this comments suggestions:&nbsp;[http://stackoverflow.com/a/186844](http://stackoverflow.com/a/186844)

And that's it. Just make sure you log everything, so that when something bad happens (and something bad always happens), you can resolve the issue as quickly as possible.
