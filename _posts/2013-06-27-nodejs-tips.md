---
layout: post
title:  "Node.js Tips"
date:   2013-06-27
---

Here are some useful notes regarding Node.js development.

#### npm --save
When I first learned how to use npm, the process was like this:
```bash
npm install <package>
vi package.json # edit the dependencies manually, and have the package version be '*'
```
which was a huge pain. Turns out, there is a great command-line flag which will add the module to package.json automatically.
```bash
npm install <package> --save # save to package.json with version
npm install <package> --save-dev # save to dev dependencies
```
#### npm local install
Installing dependencies globally (-g) can be quite scary because by default you have to sudo the command. In order to bypass this, we can compile npm to install locally to our home folder, and then add that folder to our path (.local directory). ([source](http://tnovelli.net/blog/blog.2011-08-27.node-npm-user-install.html))
```bash
wget http://nodejs.org/dist/v0.10.12/node-v0.10.12.tar.gz
tar zxvf node-v0.10.12.tar.gz
cd node-v0.10.12

./configure --prefix=~/.local
make
make install

export PATH=$HOME/.local/bin:$PATH
```
#### npm publish
Publishing a module on npm couldn't be easier (take from this&nbsp;[gist](https://gist.github.com/coolaj86/1318304)):
```bash
npm set init.author.name "Your Name"
npm set init.author.email "you@example.com"
npm set init.author.url "http://yourblog.com"

npm adduser

cd /path/to/your-project
npm init

npm publish .
```
#### --expose-gc</span>
The V8 javascript garbage collector in node.js is usually pretty good, however there may be some times when you need fine control over the collection yourself. In those cases, this command is quite useful:
```
node --expose-gc app.js
```
```
global.gc(); # within app.js
```
#### npm link
Sometimes I find myself needing to modify an npm module, either to fix a bug or add a feature. In order to test my local modifications, and use my version across apps easily, I can use `npm link`:
```bash
git  clone git@github.com:Zolmeister/Polish.js.git
cd Polish.js
npm link

cd ~/path/to/app
npm link polish # instead of npm install polish
```
#### Bonus - Great modules:
[socket.io](https://github.com/learnboost/socket.io/) - realtime websockets magic
[request](https://github.com/mikeal/request)&nbsp;- making http requests easier (like the [python library](https://github.com/kennethreitz/requests))
[passport](https://github.com/jaredhanson/passport) - user authentication
[Q](https://github.com/kriskowal/q) - great [promise](http://blog.parse.com/2013/01/29/whats-so-great-about-javascript-promises/) library
[async](https://github.com/caolan/async) - if you're not cool enough for promises
[lodash](http://lodash.com/) - better than [underscore](http://underscorejs.org/)
[fs-extra](https://github.com/jprichardson/node-fs-extra) - lets you actually copy/paste/rm -rf files/folders properly
[mongojs](https://github.com/gett/mongojs) - great library for working with mongodb
[nodejitsu reccomendations](http://blog.nodejitsu.com/6-must-have-nodejs-modules)</div>
