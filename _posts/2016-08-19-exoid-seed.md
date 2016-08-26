INCOMPLETE! SEE BELOW!!!!

---
layout: post
title:  "Exoid Seed"
date:   2016-08-18
---

### Exoid Seed - NodeJS API starter project

[Exoid Seed](https://github.com/Zorium/exoid-seed) is a simple NodeJS API seed project, for creating [Exoid](https://github.com/Zorium/exoid)-compatible services.

The Exoid protocol is a simple batch-rpc protocol, with efficient local object caching. Check out my post on [Exoid](xxINSERT LINK TO POSTxx) for more information about the protocol.
Here I will highlight some of the features of the seed project.

### Auto-fork for using multiple threads

NodeJS runs JavaScript single-threaded, so in order to better utilize system resources we create multiple copies of our server process via fork (using the built-in cluster module).

```
# bin/server.coffee
cluster = require 'cluster'
os = require 'os'
app = require '../app' # Express entrypoint

if cluster.isMaster
  _.map _.range(os.cpus().length), ->
    cluster.fork()

  cluster.on 'exit', -> # Worker died, respawn
    cluster.fork()
else
  app.listen config.PORT, -> null # worker started
```

### Simple User and Auth Model

For details on JWT authentication, check out my previous post: xxINSERT LINK TO PREVIOUS JWT AUTH POSTxx

First we look at the User model, which will persist data to RethinkDB.

```
# models/user.coffee
defaults = (user) ->
  unless user?
    return null

  _.assign {
    id: uuid.v4()
    username: null
  }, user

class UserModel
  RETHINK_TABLES: [{
    name: USERS_TABLE
    indexes: [{name: 'username'}]
  }]

  create: (user) ->
    user = defaults user
    r.table USERS_TABLE
    .insert(user).run().then -> user

  getById: (id) ->
    r.table USERS_TABLE
    .get(id).run().then defaults

  updateById: (id, diff) ->
    r.table USERS_TABLE
    .get(id).update(diff).run()

  sanitize: (user) -> # whitelist
    _.pick user, ['id', 'username']
```

Next we define a schema, which we'll be using to validate incoming requests and end-to-end tests.

```
# schema.coffee
Joi = require 'joi'
uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/

id =  Joi.string().regex uuidRegex
user =
  id: id
  username: Joi.string().allow(null)

module.exports = {id, user}
```

Finally we have the controller, which will be our api interface point. This relies on exoid-router for input validation (and subsequent error reporting).

```
# controllers/user.coffee
router = require 'exoid-router'
User = require '../models/user'
schemas = require '../schemas'

class UserCtrl
  getMe: ({}, {user}) ->
    User.sanitize(null, user)

  updateMe: ({username}, {user}) ->
    router.assert {username}, {
      username: schemas.user.username
    }

    User.updateById(user.id, {username})
    .then -> null
```


### End-to-end tests with code coverage

Test driven development can be fantastic when setup correctly. Here we leverage [Mocha](https://github.com/mochajs/mocha) and [Istanbul](https://github.com/gotwarlost/istanbul) to run our tests and print out code coverage.

```
gulp.task 'test', ->
    gulp.src paths.cover
    .pipe istanbul includeUntested: true
    .pipe istanbul.hookRequire()
    .on 'finish', ->
      gulp.src paths.test
      .pipe mocha(timeout: 5000, useColors: true)
      .pipe istanbul.writeReports()
      .once 'end', -> process.exit()
```

Our tests are written using [flare-gun](https://github.com/Zolmeister/flare-gun). To learn more about flare-gun, check out my blog post here: xxINSERT LINK TO FLARE_GUN BLOG POSTxx

```
server = require '../../index'
schemas = require '../../schemas'
flare = require('flare-gun').express(server.app)

describe 'User Routes', ->
  describe 'users.getMe', ->
    it 'returns user', ->
      flare
        .thru login()
        .exoid 'users.getMe'
        .expect schemas.user

  describe 'users.updateMe', ->
    it 'updates user', ->
      flare
        .thru login()
        .exoid 'users.updateMe', {username: 'changed'}
        .exoid 'users.getMe'
        .expect _.defaults {
          username: 'changed'
        }, schemas.user

    describe '400', ->
      it 'fails if invalid update values', ->
        flare
          .thru login()
          .exoid 'users.updateMe', {username: 123}
          .expect 400

      it 'returns 401 if user not authed', ->
        flare
          .exoid 'users.updateMe', {username: 'changed'}
          .expect 401

login = ->
  (flare) ->
    flare
    .exoid 'auth.login'
    .stash 'me'
    .actor 'me',
      qs:
        'accessToken': ':me.accessToken'
    .as 'me'
```

### Docker

Finally included is a Docker file, because Docker is great.

```
FROM node:4.2.2

# Cache dependencies
COPY npm-shrinkwrap.json /tmp/npm-shrinkwrap.json
COPY package.json /tmp/package.json
RUN mkdir -p /opt/app && \
    cd /opt/app && \
    cp /tmp/npm-shrinkwrap.json . && \
    cp /tmp/package.json . && \
    npm install --production --unsafe-perm --loglevel warn

COPY . /opt/app
WORKDIR /opt/app
CMD ["npm", "start"]
```
