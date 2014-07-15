---
layout: post
title:  "CharityVid - Front-end Optimization"
date:   2013-06-14
---

I've written a lot about the [backend](http://www.zolmeister.com/2013/05/charityvid-server-configuration.html) behind [CharityVid](http://charityvid.org/), but there is quite a bit of front things that get overlooked when developing a web application. Specifically, front end optimization (eg. page load times, browser compatibility, server latency, etc.) Let's begin with page load.

There are many good tools for measuring page load times, but these are my favorite:

*   [Google Page Speed](https://developers.google.com/speed/pagespeed/insights)
*   [Yahoo YSlow](http://developer.yahoo.com/yslow/)
*   [Chrome Developer Tools Network Tab](https://developers.google.com/chrome-developer-tools/docs/network)<div>(note:&nbsp;[http://gtmetrix.com/](http://gtmetrix.com/)&nbsp;will test your site with PageSpeed and YSlow at the same time)

With these tools we can analyse what resources are consuming the most bandwidth and compensate accordingly, as well as making sure that we are using all available methods for minimizing server load/latency. (CharityVid gets a 97% on PageSpeed, and 83% on YSlow).

Hopefully those tools are self explanatory, (don't feel like you need to to get to 100% on Page Speed/YSlow), usually just taking advantages of easy wins (like caching) is enough to make your site fast enough (aim for ~90%+ on PageSpeed and you should be good).

Here are some helpful snippets for express:

```js
     app.configure('production', function() {
       app.use(express.logger())
       app.use(express.compress()) //gzip all the things
     })
```

```js
     //force non-www
     app.get('/*', function(req, res, next) {
       if (req.headers.host.match(/^www/) !== null ) res.redirect(301,'http://' + req.headers.host.replace(/^www\./, '') + req.url);
       else next();
     });
```
Next up is browser compatibility. Hopefully you don't have to support ie6, but even then browsers like ie 7 (mostly gone), ie8, ie9, ie10 are still a pain to work with. This is especially true because in order to test these out on a real computer (running linux), you have to install a windows VM. Tools like&nbsp;[http://browsershots.org/](http://browsershots.org/)&nbsp;let you see your site running in other browsers pretty well, but this is just a quick check though, if you really want to support IE (which you shouldn't) then test it in a VM.

Finally, we get to <meta> tags (and such). Let me make it easy, and I'll just post what I use:

```html
     <meta charset="utf-8">
     <meta name="description" content="Be the difference, support charity just by watching a video.">
     <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
     <meta name="twitter:card" content="summary">
     <meta name="twitter:url" content="http://charityvid.org">
     <meta name="twitter:title" content="CharityVid">
     <meta name="twitter:description" content="CharityVid is dedicated to enabling people to donate to charity, even if all they can afford is their time. By donating just a few minutes day you can make a difference.">
     <meta name="twitter:image" content="http://charityvid.org/ico/apple-touch-icon-144-precomposed.png">
     <link rel="shortcut icon" href="/ico/favicon.ico">
     <link rel="apple-touch-icon-precomposed" sizes="144x144" href="/ico/apple-touch-icon-144-precomposed.png">
     <link rel="apple-touch-icon-precomposed" sizes="114x114" href="/ico/apple-touch-icon-114-precomposed.png">
     <link rel="apple-touch-icon-precomposed" sizes="72x72" href="/ico/apple-touch-icon-72-precomposed.png">
     <link rel="apple-touch-icon-precomposed" href="/ico/apple-touch-icon-57-precomposed.png">
```
You should notice two things: I don't have a 'keywords' meta tag, and I have apple-touch-icon's.

As far as the keywords tag goes, I have read in many places that it isn't even looked at for SEO, and Google doesn't use it on its home page, so I decided to omit it. Apple-touch icons are used for when mobile users (both Android and iPhone) want to save your website as an application (it's just a web link, but shows up next to other native applications).

There is actually a lot more I could write about, however It's easier to provide relevant links to what others have written on the subject.
[Web Dev Checklist](http://webdevchecklist.com/) # Extremely useful for all websites, definitely check this one out
[Fantastic Front End Performance - Mozilla](https://hacks.mozilla.org/2012/12/fantastic-front-end-performance-part-1-concatenate-compress-cache-a-node-js-holiday-season-part-4/)&nbsp;([part 2](https://hacks.mozilla.org/2013/02/fantastic-front-end-performance-in-node-part-2-a-node-js-holiday-season-part-6/),&nbsp;[part 3](https://hacks.mozilla.org/2013/03/fantastic-front-end-performance-part-3-big-performance-wins-by-optimizing-fonts-a-node-js-holiday-season-part-8/)) # this focuses on node.js performance
[Blitz.io](http://blitz.io/)&nbsp;# Load testing, for testing both the server availability as well as latency
[SEO Site Checkup](http://www.seositecheckup.com/) # Checks websites for basic SEO best practices
[Yahoo Smush It](http://www.smushit.com/ysmush.it/)&nbsp;# Lossless Image file compression

Lastly, I highly recommend [grunt](http://gruntjs.com/)&nbsp;(charityvid will be using this soon) to automate any compression/minification of files (all js should be concatenated and minified, same with css, and images should be compressed with SmushIt or similar).

Grunt seemed a bit daunting at a glance, but its actually quite simple. Here is an example Gruntfile.js:

```js
    module.exports = function(grunt) {
      grunt.initConfig({
       concat: {
        dist: {
         src: ['public/js/**/*.js'],
         dest: 'public/prod/js/production.js'
        }
       },
       uglify: {
        dist: {
         files: {
          'public/prod/js/production.min.js': ['public/prod/js/production.js']
         }
        }
       }
      });
      grunt.loadNpmTasks('grunt-contrib-uglify');
      grunt.loadNpmTasks('grunt-contrib-concat');
      grunt.registerTask('compress', ['concat', 'uglify']);
     };
```
Just run 'grunt compress', and you should be good to go (don't forget to npm install -g grunt-cli).
