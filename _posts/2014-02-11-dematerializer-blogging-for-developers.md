---
layout: post
title:  "Dematerializer - Blogging for developers"
date:   2014-02-11
---

[<img src="http://1.bp.blogspot.com/-eDTRKhEo3Nk/UvnTBuNfD8I/AAAAAAAAB3g/0Tp203WCTlQ/s1600/Selection_086.png">](http://dematerializer.zolmeister.com/#/)

#### [Dematerializer](http://dematerializer.zolmeister.com/#/) ([Source](https://github.com/Zolmeister/dematerializer))
Inspired by [Ghost](https://ghost.org/), Dematerializer was my submission to [Static Showdown](http://www.staticshowdown.com/app/teams/55dbeca986f875e1d1cb4d51e2fc42e4/entry), a 48hr hackathon with a twist; the app must be static (i.e. no custom back-end). At first it seemed like a huge restriction, however after exploring services like&nbsp;[Firebase](https://www.firebase.com/)&nbsp;(a websockets enabled database-as-a-service) I realized that almost anything was possible.

What makes Dematerializer different than other blogging platforms is that posts are written entirely in [Markdown](https://daringfireball.net/projects/markdown/) (with an auto-scrolling instant preview pane), and that it is completely free and open so that anyone can start blogging instantly. It is similar to the Ghost platform, only far simpler and completely free.

I ended up using [AngularJS](http://angularjs.org/), [Firebase](https://www.firebase.com/), [Gulp](http://gulpjs.com/), [Pure CSS](http://purecss.io/), [Google Web Fonts](http://www.google.com/fonts), and a few libraries ([lodash.js](http://lodash.com/), [marked.js](https://github.com/chjj/marked), [highlight.js](http://highlightjs.org/), [spin.js](http://fgnass.github.io/spin.js/)). The code is pretty standard AngularJS, and for the most part follows best practices. This was my first time using Gulp (instead of [Grunt](http://gruntjs.com/)), and I highly recommend it. When I wrote about re-writing [Zoggle in AngularJS](http://www.zolmeister.com/2014/01/zoggle-rewritten-using-angularjs.html), I posted my Gruntfile which minified my AngularJS source. Looking at the Gulp equivalent, it's clear how powerful Gulp can be:

```js
// Concatenate & Minify JS
gulp.task('scripts', function() {
    gulp.src('./app/js/*.js')
        .pipe(concat('all.js'))
        .pipe(ngmin())
        .pipe(gulp.dest('./app/dist'))
        .pipe(rename('all.min.js'))
        .pipe(uglify())
        .pipe(gulp.dest('./app/dist'));
});
```
As for the front-end code itself, the Firebase service I wrote for the application provides the core functionality. This code allows users to create, read, update, and delete posts that they own:

```js
.service('DBService', function () {
    this.db = new Firebase('https://glaring-fire-7868.firebaseio.com/')
    this.postDB = this.db.child('posts')
    this.createPost = function (post, uid, cb) {
      this.postDB.child(uid).child(post.id).set(post, cb)
    }
    this.findPost = function (postId, uid, cb) {
      this.postDB.child(uid).child(postId).once('value', cb)
    }
    this.posts = function (uid, cb) {
      if (!cb) {
        cb = uid
        uid = null
      }
      if (uid) {
        this.postDB.child(uid).once('value', cb)
      } else {
        this.postDB.once('value', cb)
      }
    }
    this.removePost = function (postId, uid, cb) {
        this.postDB.child(uid).child(postId).remove(cb)
    }
  })
```
Firebase uses a simple json object to define data-access for users. Here was mine:

```js
{
  "rules": {
    ".read": true,
    "posts": {
      "$user": {
        ".read": true,
        ".write": "$user == auth.username",
        "$post": {
          ".read": true,
          ".write": "data.child('$user').val() == auth.username"
        }
      }
    }
  }
}
```
Finally, I used&nbsp;[CSS Flexible boxes](https://developer.mozilla.org/en-US/docs/Web/Guide/CSS/Flexible_boxes), which are an extremely powerful way to have flexible sized content using only CSS. You can see them in action by re-sizing the application, which is quite usable on mobile despite not optimizing for it.
