---
layout: post
title:  "How to deploy node.js applications"
date:   2012-12-10
---

[<img src="http://www.ascendtraining.com/blog/wp-content/uploads/2012/11/aws.png">](http://www.ascendtraining.com/blog/wp-content/uploads/2012/11/aws.png)

I am currently running 5&nbsp;websites on my free (1 year) Amazon EC2 [micro instace](http://aws.amazon.com/ec2/pricing/?_encoding=UTF8&camp=1789&creative=9325&linkCode=ur2&tag=zolmeister-20)![](http://www.assoc-amazon.com/e/ir?t=zolmeister-20&l=ur2&o=1). Every one of these urls corresponds to a&nbsp;separate&nbsp;node.js service running on the server:  
[http://zoggle.zolmeister.com/](http://zoggle.zolmeister.com/)  
[http://games.zolmeister.com/](http://games.zolmeister.com/)  
[http://avabranch.zolmeister.com/](http://avabranch.zolmeister.com/)  
[http://gallery.zolmeister.com/](http://gallery.zolmeister.com/)  
[http://charityvid.org/](http://charityvid.org/)  

Let me preface this by saying that the way I deployed my sites before was the following:

*   ssh myserver@amazonec2
*   screen -ls (to display all the screen instances I had open)
*   screen -r XXXX (guess at which screen was the one running the site I wanted to update)
*   node app.js (launch a server process in the screen, and then Ctrl+a+d to detach from the screen)This is obviously&nbsp;inefficient&nbsp;and slow, and by the time I got to running 5 websites (and 1 proxy service to direct traffic) I decided I needed a more efficient way of deploying and managing my sites.

[![](http://upstart.ubuntu.com/img/upstart80.png)](http://upstart.ubuntu.com/img/upstart80.png)
Enter [upstart](http://upstart.ubuntu.com/), the /sbin/init replacement. Upstart lets you maintain just one config file per site and start and stop it as a service without the need to run everything in a screen. To deploy an app is as simple as copying the myapplication.conf file into /etc/init/ and running "start myapplication". Here is an example of one of my conf files (modified from [this site](http://kvz.io/blog/2009/12/15/run-nodejs-as-a-service-on-ubuntu-karmic/)):

```
     description "CharityVid node server"
     author   "Zolmeister"
     stop on shutdown
     respawn
     respawn limit 20 5
     # Max open files are @ 1024 by default. Bit few.
     limit nofile 32768 32768
     script
          echo $$ > /var/run/charityvid.pid
          export NODE_ENV=production
          cd /home/pi/websites/charityvid
          exec /usr/local/bin/up -p 3100 -w app.js 2>&1 >> /var/log/charityvid.log
     end script
```
What this conf file says is that on service start, log the&nbsp;process's&nbsp;pid (in case we need to kill it), set node to production mode, cd into the site directory (this is necessary because of&nbsp;issues with express.js template loading), and finally start the app. Notice that I start the app with the "up" command, and that I am piping 2>&1 (std err to std out) and appending (>>) it to the log file. The "up" command comes from the [up node module](https://github.com/LearnBoost/up)&nbsp;which does auto-updating and load balancing. The alternative to "up" is [node-supervisor](https://github.com/isaacs/node-supervisor)&nbsp;which doesn't do load balancing but can be run on any application out of the box (without the&nbsp;modification&nbsp;required by "up").

Ok, so now we have a way to start all of our applications, but how to route all the connections to the right place (remember all our apps are on one server with one IP address). Normally you would use [NGINX](http://nginx.org/) (pronounced "engine x"), but the stable branch doesn't support websockets (used by [http://zoggle.zolmeister.com](http://zoggle.zolmeister.com/)) so I decided to go with the simple [node-http-proxy](https://github.com/nodejitsu/node-http-proxy) module. The documentation is a bit lacking, but I was able to get all the sites routed, including websockets support and ssl support (for&nbsp;[https://charityvid.org/](https://charityvid.org/)). Here is what my app.js file looks like for my "gateway" application:

```js
var http = require('http'),
    httpProxy = require('http-proxy'),
    fs = require('fs'),
    https = require('https'),
    crypto = require("crypto"),
    path = require('path');
var main1 = httpProxy.createServer({
  router: {
    'zoggle.zolmeister.com': 'localhost:3001',
    'avabranch.zolmeister.com': 'localhost:3005',
    'charityvid.org': 'localhost:3100'
  }
});
main1.listen(8000);
var proxy = new httpProxy.HttpProxy({
  target: {
    host: 'localhost',
    port: 8000
  }
});
var server = http.createServer(function (req, res) {
  // Proxy normal HTTP requests
  proxy.proxyRequest(req, res);
});
server.on('upgrade', function (req, socket, head) {
  // Proxy websocket requests too
  proxy.proxyWebSocketRequest(req, socket, head);
});
server.listen(80);

function getCredentialsContext(cer) {
  return crypto.createCredentials({
    key: fs.readFileSync(path.join(__dirname, 'certs', cer + '.key')),
    cert: fs.readFileSync(path.join(__dirname, 'certs', cer + '.crt'))
  }).context;
}
var certs = {
  "charityvid.org": getCredentialsContext("charityvid")
};
var options = {
  https: {
    SNICallback: function (hostname) {
      return certs[hostname];
    }
  },
  hostnameOnly: true,
  router: {
    'charityvid.org': 'localhost:3100'
  }
};
// https
httpProxy.createServer(options).listen(443);
```
After running the routing proxy every site should now be functional and up, but we still have to ssh into the server to start/stop apps and to update them (with supervisor and up you should rarely have to restart the node server). This is where [fabric](http://docs.fabfile.org/en/1.5/) comes in. Fabric lets you automate the ssh process and run commands on the server from your work machine. For example a simple command to send the initial application.conf upstart file would be:

```python
def installInit():
	put('avabranch.conf', '/etc/init/avabranch.conf', True)
	sudo('touch /var/log/avabranch.log')
	sudo('chown admin /var/log/avabranch.log')
```
And if you're using git to manage your source (I store mine in a private [bitbucket](https://bitbucket.org/) repo), updating your production code is as easy as "fab update:avabranch" with the following fab file declaration:

```python
def update(app):
	with cd('/home/admin/websites'):
		if app=="avabranch":
			run('cd avabranch && git pull')
```
Finally I keep my sites behind the [Cloud Flare](http://www.cloudflare.com/) service, which basically means that they are protected from DDOS attacks, plus get free and efficient localized caching (cloud flare has many&nbsp;data-centers&nbsp;all over the world, which allows them to improve site cache latency times).
