INCOMPLETE!!! SEE BELOW!

---
layout: post
title:  "Zorium Seed"
date:   2016-05-04
---

xxINSERT IMAGE (diagram of component-model-cache) HERExx

### Zorium Seed

Zorium Seed represents a state-of-the-art client-side single-page-application starter project, based on [Zorium](https://github.com/Zorium/zorium) and [Exoid](https://github.com/Zorium/exoid).
For more information on those, check out my [Zorium](xxINSERT LINK HERExx) and [Exoid](xxINSERt LINK HERExx) blog posts.

# Gulp Commands

For details on functional tests see [Functional tests](#Functional tests) TODO CHECK THIS LINK

- `npm run dev`
  - start webpack dev server, with live updates
- `npm run dist`
  - build bundle.js from source files (coffee and stylus)
- `npm start`
  - start production server (no webpack, run after `dist`)
- `npm test`
  - run unit tests in the browser with code coverage
- `npm test-functional`
  - run selenium tests with multiple browsers
- `npm run watch`
  - watch for changes and run unit tests
- `npm run watch -- phantom`
  - use phantom headless browser for unit tests
- `npm run watch -- server`
  - watch server end-to-end tests
- `npm run watch -- functional`
  - watch functional tests with headless chrome browser against live running local instance
- `npm run sauce-tunnel`
  - start remote saucelabs tunnel for foreign browser tests

# Exoid Model Cache

Zorium-Seed uses the Exoid protocol (see my blog post here: xxINSERT LINK TO POSTxx) for efficient network communications. Here's a simple diagram explaining the server-side rendering and caching process.

xxINSERT DIAGRAM HERExx

Here's a simplified version of the base model. We proxy header information for when requests are made server-side. Note that we also use the `auth` model as middleware for requests (see next section). The global `window` cache is set in the header of the page (see header section below).

```coffee
module.exports = class Model
  constructor: ({cookieSubject, serverHeaders}) ->
    cache = window?[SERIALIZATION_KEY] or {}
    accessToken = cookieSubject.map (cookies) ->
      cookies[config.AUTH_COOKIE]

    proxy = (url, opts) ->
      accessToken.take(1).toPromise()
      .then (accessToken) ->
        proxyHeaders =  _.pick serverHeaders, ['cookie', 'user-agent']
        request url, _.merge {
          qs: {accessToken}
          headers: proxyHeaders
        }, opts

    @exoid = new Exoid
      api: config.API_URL + '/exoid'
      fetch: proxy
      cache: cache.exoid

    @auth = new Auth({@exoid, cookieSubject})
    @user = new User({@auth})
```

This efficient structure is what allows us to write simple models and components that are easy to reason about.

```coffee
# models/user.coffee
module.exports = class User
  constructor: ({@auth}) -> null
  getMe: =>
    @auth.stream 'users.getMe'
# models/example.coffee  
module.exports = class Example
  constructor: ({@auth}) -> null
  getCount: =>
    @auth.stream('count.get').map ({count}) -> count
  incrementCount: =>
    @auth.call 'count.inc'
```

```coffee
# components/hello_world.coffee
Button = require 'zorium-paper/button'
module.exports = class HelloWorld
  constructor: ({model, router}) ->
    @$increment = new Button({
      $children: 'increment counter'
      onclick: _.partial @increment, model
    })

    @state = z.state
      count: model.example.getCount()
      username: model.user.getMe().map ({username}) -> username

  increment: (model) ->
    model.example.incrementCount().catch log.error

  render: =>
    {username, count} = @state.getValue()

    z '.z-hello-world',
        z '.username',
          "username: #{username}"
        z '.count',
          "count: #{count}"
        @$increment
```

# Routing

Routing is accomplished via passing a `LocationRouter` ([location-router](https://github.com/Zorium/location-router)) instance to components which change the URL.

```coffee
module.exports = class Red
  constructor: ({router}) ->
    @$button = new Button({
      $children: 'click me'
      onclick: _.partial @goToHome, router
    })

  goToHome: (router) ->
    router.go '/home'

  render: =>
    z '.z-red',
      z '.t-click-me',
        @$button
```

# Cookies

Cookies (both getting and setting) are interfaced the same when code runs either client-side or server-side. To facilitate this, we create a RxJS Subject which persists changes and allows watchers.

```coffee
# client side setup
setCookies = (currentCookies) ->
  (cookies) ->
    _.map cookies, (value, key) ->
      unless currentCookies[key] is value
        document.cookie = cookie.serialize \
          key, value, CookieService.getCookieOpts()
    currentCookies = cookies

init = ->
  currentCookies = cookie.parse(document.cookie)
  cookieSubject = new Rx.BehaviorSubject currentCookies
  cookieSubject.subscribeOnNext setCookies(currentCookies)
  # Now we can write and read cookies with cookieSubject
```

```coffee
# server side setup
app.use (req, res, next) ->
  setCookies = (currentCookies) ->
    (cookies) ->
      _.map cookies, (value, key) ->
        unless currentCookies[key] is value
          res.cookie(key, value, CookieService.getCookieOpts())
      currentCookies = cookies

  cookieSubject = new Rx.BehaviorSubject req.cookies
  cookieSubject.subscribeOnNext setCookies(req.cookies)
  # treat cookieSubject the same as client-side
```

# Auth Model

The Auth model is used as middleware between other models and Exoid, and handles setting the appropriate `accressToken` query string for requests. We have multiple states to consider when running auth.

  - No existing auth cookie
    - call `auth.login` remotely to get an anonymous user accessToken, and update cookies
  - Existing auth cookie
    - If we have a local user (returned by `users.getMe`) cached client-side, we trust auth to be correct
    - Otherwise we must validate that the cookie is valid by calling `users.getMe`
    - If invalid, `users.getMe` will fail, so we know to call `auth.login` and replace the cookie with a new user

```coffee
module.exports = class Auth
  constructor: ({@exoid, cookieSubject}) ->
    initPromise = null
    @waitValidAuthCookie = Rx.Observable.defer =>
      if initPromise?
        return initPromise
      return initPromise = cookieSubject.take(1).toPromise()
      .then (currentCookies) =>
        (if currentCookies[config.AUTH_COOKIE]?
          @exoid.getCached 'users.getMe'
          .then (user) =>
            if user?
              return {accessToken: currentCookies[config.AUTH_COOKIE]}
            @exoid.call 'users.getMe'
            .then ->
              return {accessToken: currentCookies[config.AUTH_COOKIE]}
          .catch =>
            cookieSubject.onNext _.defaults {
              "#{config.AUTH_COOKIE}": null
            }, currentCookies
            @exoid.call 'auth.login'
        else
          @exoid.call 'auth.login')
        .then ({accessToken}) ->
          cookieSubject.onNext _.defaults {
            "#{config.AUTH_COOKIE}": accessToken
          }, currentCookies

  stream: (path, body) =>
    @waitValidAuthCookie
    .flatMapLatest => @exoid.stream path, body

  call: (path, body) =>
    @waitValidAuthCookie.take(1).toPromise()
    .then => @exoid.call path, body
```

# Full Page rendering

Zorium is capable of supporting full-page rendering (i.e. render the `head` tag). So we create a `head` component, responsible for all meta tags, server-to-client caching, and script in-lining.

```coffee
module.exports = class Head
  constructor: ({model, meta, serverData}) ->
    @state = z.state
      meta: meta
      serverData: serverData
      modelSerialization: model.getSerializationStream()

  render: =>
    {meta, serverData, modelSerialization} = @state.getValue()

    meta = _.merge {
      title: 'Zorium Seed'
      description: 'Zorium Seed - (╯°□°）╯︵ ┻━┻)'
      icon256: '/images/zorium_icon_256.png'
    }, meta

    isInliningSource = config.ENV is config.ENVS.PROD
    webpackDevUrl = config.WEBPACK_DEV_URL

    z 'head',
      z 'title', "#{meta.title}"
      z 'meta', {name: 'description', content: "#{meta.description}"}
      z 'script.model', # cache serialization
        innerHTML: modelSerialization or ''
      if isInliningSource # styles
        z 'style.styles',
          innerHTML: serverData?.styles
      else
        null
      z 'script.bundle',
        async: true
        src: if isInliningSource then serverData?.bundlePath \
             else "#{webpackDevUrl}/bundle.js"
```

# Error logging

Zorium-Seed also has built-in support for client-side error reporting

```coffee
# Report errors to API_URL/log
log.on 'error', (err) ->
  try
    StackTrace.fromError err
    .then (stack) -> stack.join('\n')
    .catch (parseError) -> err
    .then (trace) ->
      window.fetch config.API_URL + '/log',
        method: 'POST'
        body: JSON.stringify
          event: 'client_error'
          trace: trace
          error: String(err)
    .catch (err) ->
      console?.log err
  catch err
    console?.log err
```

# Config

A single config file is shared between server and client, however we must not leak server information client-side. We also don't know the config variables ahead of time, so a script is used to replace source strings at runtime (`process.env.XXX` is replaced with `XXX` environment variable). We don't replace `serverEnv.XXX` (remember it's a string) in the client-side code, thus avoiding leakage.

```coffee
# Don't let server environment variables leak into client code
serverEnv = process.env

# All keys must have values at run-time (value may be null)
isomorphic =
  HOST: process.env.HOST or '127.0.0.1'
  API_URL:
    serverEnv.PRIVATE_API_URL or # server
    process.env.API_URL or # client
    'http://127.0.0.1:3005' # default
```

# Server Tests With Zock

In order to test full-page rendering without a server, we use [Zock](https://github.com/Zolmeister/zock) to create mock responses to API calls (and [flare-gun](https://github.com/Zolmeister/flare-gun) to make real requests). For more information about Zock, check out my blog post here: xxINSERT LINK TO BLOG POSTxx

```coffee
flareGun = require 'flare-gun'
zock = require 'zock'

app = require '../../server'
flare = flareGun.express(app)
after ->
  flare.close()

describe 'server', ->
  it 'renders /', ->
    zock
    .base config.API_URL
    .exoid 'users.create'
    .reply {}
    .exoid 'users.getMe'
    .reply {}
    .exoid 'count.get'
    .reply {}
    .withOverrides ->
      flare
        .get '/'
        .expect 200

  it 'renders /404', ->
    flare
      .get '/404'
      .expect 404
```

# Functional Tests

Functional tests use [Webdriver.io](http://webdriver.io/) to provide a selenium interface. These tests are meant to be run in a full-stack environment (i.e. with live API servers) as opposed to the server-side unit tests.

```coffee
b = require 'b-assert'
url = require 'url'

describe 'functional tests', ->
  it 'checks title', ->
    client
      .getTitle()
      .then (title) ->
        b title, 'Zorium Seed'

  it 'navigates on button click', ->
    client
      .click '.p-home .z-hello-world .t-click-me'
      .url()
      .then ({value}) ->
        b url.parse(value).pathname, '/red'
      .waitForVisible '.p-red .z-red .t-click-me'
      .click '.p-red .z-red .t-click-me'
      .url()
      .then ({value}) ->
        b url.parse(value).pathname, '/'
```

# Docker

Finally we have a Dockerfile for simple deployment.

```
FROM node:4.2.3

# npm-shrinkwrap.json, package.json
COPY *.json /tmp/
RUN mkdir -p /opt/app && \
    cd /opt/app && \
    cp /tmp/npm-shrinkwrap.json . && \
    cp /tmp/package.json . && \
    npm install --production --unsafe-perm --loglevel warn

COPY . /opt/app
WORKDIR /opt/app
CMD ["npm", "start"]
```
