---
layout: post
title:  "CharityVid - User Auth, Jasmine Testing, and Dust.js"
date:   2013-07-07
---

This is the last (official) post in my [CharityVid](http://charityvid.org/) series. I'm going to try and cram 3 big topics into one post, so lets see how it goes.

### User Authentication
We're going to be using [passport.js](http://passportjs.org/)&nbsp;and [MongoDB](http://www.mongodb.org/) to create and store users. Here is what the passport code will look like:

```js
     var passport = require('passport'),
       FacebookStrategy = require('passport-facebook').Strategy,
       db = require('./db'),
       settings = require('./settings'),
       log = require('./log');
     passport.use(new FacebookStrategy({
       clientID: FACEBOOK_APP_ID,
       clientSecret: FACEBOOK_APP_SECRET,
       callbackURL: "//" + settings.DOMAIN + "/auth/facebook/callback"
     }, function(accessToken, refreshToken, profile, done) {
       db.getUser(profile.id, function(err, result){
         if (err || !result) { //user does not exist, create
           //default user object
           var user = {
             fbid: profile.id,
             username: profile.username,
             displayName: profile.displayName,
             ...
           }
           log.info("creating new user: "+user.fbid, user)
           db.addUser(user, function(err, result) {
             if(err || !result){
               log.warn("error adding user", err)
               return done(err)
             }
             return done(null, user)
           })
         } else {
           return done(null, result)
         }
       })
     }))
     passport.serializeUser(function(user, done) {
       done(null, user)
     })
     passport.deserializeUser(function(obj, done) {
       done(null, obj)
     })
```
and then we need to add it in as express middleware.

```js
app.configure(function() {
       app.use(express.cookieParser(settings.SESSION_SECRET))
       app.use(express.session({
         secret: settings.SESSION_SECRET,
         store: new MongoStore({
           url: settings.MONGO_URL
         })
       })) //auth
       app.use(passport.initialize())
       app.use(passport.session()) //defaults
     })
     app.get('/auth/facebook/callback', auth.passport.authenticate('facebook', {
       failureRedirect: '/'
     }), function(req, res) {
       res.redirect('/')
     })
     app.get('/logout', function(req, res) {
       req.logout()
       res.redirect('/')
     })
     app.get('/auth/facebook', auth.passport.authenticate('facebook'), function(req, res) { /* function will not be called.(redirected to Facebook for authentication)*/
     })
```
Well that was a piece of cake, onto testing!

### Testing
There are many kinds of testing ([http://en.wikipedia.org/wiki/Software_testing#Testing_levels](http://en.wikipedia.org/wiki/Software_testing#Testing_levels)), and its up to you to decide how much or how little of it you wan't to do. CharityVid uses [Jasmine-node](https://github.com/mhevery/jasmine-node)&nbsp;for its tests. We have a folder named 'tests', and inside are javascript files named '<part of code>.spec.js'. The .spec.js extension tells jasmine that these are tests to run. Here is what a test might look like with jasmine:

```js
describe("Util check", function() {
       var belt = require('../util')
        it("retrieves charity data", function(done) {
            belt.onDataReady(function() {
                belt.getCharity("americanredcross", function(err, charity) {
                    expect(charity.name).toBeDefined()
                    expect(charity.website).toBeDefined()
                    ...
                    done()
                })
            })
        })
     })
```
And then to test it:

```
jasmine-node tests
```
And now finally, onto Dust.js

### Dust.js
CharityVid uses&nbsp;[Dust.js](http://linkedin.github.io/dustjs/), which&nbsp;is a [template engine](http://en.wikipedia.org/wiki/Template_engine_%28web%29), similar to [Jade](http://jade-lang.com/), the default template engine used by express.js. Dust has a some nice features, including pre-compiled client side templates that can also be used server side (pre-compiling reduces the initial load times). Using dust.js is as simple as setting the view engine:

```js
var cons = require('consolidate')
     app.engine('dust', cons.dust) //dustjs template engine
     app.configure(function() {
       app.set('view engine', 'dust') //dust.js default
     })
```
The dust engine comes from the [Consolidate.js](https://github.com/visionmedia/consolidate.js/)&nbsp;library, which supports a ton of different engines.

Here is an example of what dust.js looks like:

```
{>"base.dust"/}
     {<css_extra}<link href="/css/profile.css" rel="stylesheet">{/css_extra}
     {<title}CharityVid - {name}{/title}
     {<meta_extra}
     <meta property="og:title" content="{name} - CharityVid"/>
     {/meta_extra}
     {<js}<script src='/js/profile.js' async></script>{/js}
     {<profile_nav}class="active"{/profile_nav}
     {<container}
     <h1>{name}</h1>
     <div class="row-fluid">
       <img alt='{name}' class='profile-picture' src='https://graph.facebook.com/{fbid}/picture?type=large' align="left">
       <span id='userQuote'>{quote}</span>
       {?isUser}
           <a class='edit' id='editQuote' href='#'>edit</a>
       {/isUser}
       <input type='hidden' name='_csrf' id='csrfToken' value='{token}'>
     </div>
     {/container}

```
