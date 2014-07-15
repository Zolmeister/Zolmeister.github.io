---
layout: post
title:  "Zoggle - Rewritten Using AngularJS"
date:   2014-01-07
---

[![](http://4.bp.blogspot.com/-2mf8hrqg5zw/UsdX3VlNL9I/AAAAAAAABkk/acSzRrCi4Xs/s640/banner2.png)](http://4.bp.blogspot.com/-2mf8hrqg5zw/UsdX3VlNL9I/AAAAAAAABkk/acSzRrCi4Xs/s1600/banner2.png)

#### Zoggle, the ultimate word game!
Play [Zoggle](http://zoggle.zolmeister.com/) ([source](https://github.com/Zolmeister/Zoggle)) FREE on:

[<img border="0" src="http://1.bp.blogspot.com/-Yzf7q1IiKzA/UstA9JrjQLI/AAAAAAAABlU/y5lvJ4PXpGA/s1600/icon.png" height="80">](http://zoggle.zolmeister.com/)

<a href="https://play.google.com/store/apps/details?id=zolmeister.zman.zoggle" imageanchor="1" style="float: left; margin-bottom: 1em; margin-right: 1em;"><img border="0" src="http://3.bp.blogspot.com/-5TYDOf_4nWo/UstXHii97zI/AAAAAAAABm8/eEaTaNLJ4tY/s1600/google_play_store_logo_ungarische-Produkte_online.png" height="80"></a>

<a href="https://chrome.google.com/webstore/detail/zoggle/makbpnhaoldbpinpacbppcefmonaimlf" imageanchor="1" style="margin-left: 1em; margin-right: 1em; text-align: center;"><img border="0" src="http://4.bp.blogspot.com/-KWn2qgBFK-k/UstTgx7kE4I/AAAAAAAABlw/NdU1RkAJQiM/s1600/blog_chrome.png" height="80"></a><br>

<a href="http://www.amazon.com/gp/product/B00HO06T1S/ref=as_li_ss_tl?ie=UTF8&amp;camp=1789&amp;creative=390957&amp;creativeASIN=B00HO06T1S&amp;linkCode=as2&amp;tag=zolmeister-20" imageanchor="1" style="clear: left; float: left; margin-bottom: 1em; margin-right: 1em;"><img border="0" src="http://1.bp.blogspot.com/-XDl9CZa98ng/UstTgotHwdI/AAAAAAAABls/o-BFWVvVUgo/s1600/amazon-icon-final-large-512512.jpg"></a>

<a href="https://marketplace.firefox.com/app/zoggle" imageanchor="1" style="margin-bottom: 1em; margin-right: 1em;"><img border="0" src="http://1.bp.blogspot.com/-iJ8wh5BLYiE/UstSg833EDI/AAAAAAAABlk/E3cHsJsht3w/s1600/firefox-marketplace_logo-wordmark_RGB.png" height="80"></a>


#### A Long Time Ago...
Zoggle was my very first app on Google Play, and also happened to be the topic of my first blog post over a year ago:&nbsp;[http://www.zolmeister.com/2012/04/zoggle.html](http://www.zolmeister.com/2012/04/zoggle.html). I finally got around to giving it a proper upgrade by rebuilding from the ground up. Zoggle is now better than ever, with a new theme, less bugs, and an illustriously impeccable code-base.

[![](http://2.bp.blogspot.com/-tItuDOFfbCY/UsuFeYxmZ0I/AAAAAAAABng/G6yomhoEsKg/s1600/zoggle1.png)](http://2.bp.blogspot.com/-tItuDOFfbCY/UsuFeYxmZ0I/AAAAAAAABng/G6yomhoEsKg/s1600/zoggle1.png) [![](http://1.bp.blogspot.com/-ushK9k-_sw4/UsuFgeOZ-CI/AAAAAAAABno/v1troMq_AMo/s1600/zoggle2.png)](http://zoggle.zolmeister.com/)

#### Round 2
[![](http://www.christopherlaughlin.co.uk/wp-content/uploads/2013/10/grunt-logo.png)](http://www.christopherlaughlin.co.uk/wp-content/uploads/2013/10/grunt-logo.png)

Originally Zoggle was built using many javascript and css hacks (not maintainable) and depended zero external libraries (not even jQuery). As a result, it quickly became messy spaghetti code, making even simple changes take hours to implement and test.

Now, after 6 days and 74 commits (and many hours of lost sleep), I finished re-writing Zoggle using [AngularJS](http://angularjs.org/), [jQuery](http://jquery.com/), [Lo-Dash](http://lodash.com/), and [Grunt](http://gruntjs.com/) to create a highly maintainable and scalable application. So, without further ado, let's go over some of the key aspects of the re-write.

[![](http://angularjs.org/img/AngularJS-large.png)](http://angularjs.org/img/AngularJS-large.png)

#### Boggle Library
While searching NPM for a boggle library (before writing my own), I came across [Boggle](https://npmjs.org/package/boggle)&nbsp;which leverages [tries](http://en.wikipedia.org/wiki/Trie) (mentioned in my [original blog post](http://www.zolmeister.com/2012/04/zoggle.html)) for optimal performance. However the library had some issues (no 'Qu' single tile support), and a poor dictionary list. I contacted the developer&nbsp;[bahmutov](https://github.com/bahmutov), got the code moved to GitHub, and added the features. (He was also awesome enough to let me push to npm and the core repo, so you may want to check out his [blog](http://bahmutov.calepin.co/)).

#### AngularJS
What can I say, except that AngularJS is absolutely amazing! It has a few bugs (you've been warned), but it is incredible to work with and makes webdev even more fun and exciting than before. If you're new to Angular, I recommend [25 days of AngularJS](http://www.ng-newsletter.com/advent2013/#!/), and checking out the [Angular-Seed](https://github.com/angular/angular-seed) project. I won't be writing a tutorial, but some things to watch out for.

#### AngularJS Gotchas

*   ~~Data-binding on primitives (string, num, bool) doesn't always work properly.~~ Update: updating primitives from views doesn't work as expected ([more info](https://github.com/angular/angular.js/wiki/Understanding-Scopes)).

*   Either nest data inside an object {} or call $scope.$apply()*   Directives can be called before the DOM is ready

#### Boggle Board
I could have rendered the board using either the DOM or Canvas (or WebGL) but I opted for using the DOM. One issue I ran across when writing the original Zoggle was that touch-move events [do not cross over elements](http://stackoverflow.com/questions/12396635/crossing-over-to-new-elements-during-touchmove). This meat that I had to use the document.elementFromPoint() function in the original Zoggle. Unfortunately, it does not perform well on mobile, so this time around I decided to overlay a div over the whole board and calculate the position of the mouse over the elements manually. Unlike the non-performant code in the [stackoverflow answer](http://stackoverflow.com/a/12397041/2780143), I cached the position of the elements so that detection would be much faster.
```js
var positions = [];

function cachePos() {
  var targets = $el.parent().find('.' + attrs.targets)
  positions = []
  targets.each(function (i, $el) {
    $el = $($el)
    positions.push({
      x: $el.offset().left,
      y: $el.offset().top,
      w: $el.outerWidth(),
      h: $el.outerHeight()
    })
  })
}

function collide(x1, y1, w1, h1, x2, y2, w2, h2) {
  if (y1 + h1 < y2 || y1 > y2 + h2 || x1 + w1 < x2 || x1 > x2 + w2) return false;
  return true
}
```

#### Letter Interpolation
The boggle board is represented internally as a single list (of 16 characters) because it made rendering easy. The logical thing (which I didn't do) would be to clone the data (as it's static per-game) and represent it as a 2D array. Anyways, one great feature I added to Zoggle was the ability to interpolate between two tiles. This means if you touch one tile (mobile device) and move too quickly and end up 2 tiles over, the algorithm will add the missing tile(s). The algorithm is pretty simple (see bonus for explanation of touching function):
```js
function touching(x1, y1, x2, y2) {
  return _.some(_.filter(_.flatten(_.map(_.range(-1,2),_.compose(_.partial(_.zip,_.range(-1,2)),_.partial(_.compose(_.partial(_.map,_.range(3)),_.partial),_.identity))),!0),_.compose(_.first,_.compact)), function(dir) {
    return x1+dir[0] === x2 && y1+dir[0] === y2
  })
}

while (!touching(x1, y1, x2, y2)) {
  // interpolate position
  if(x1 < x2) x1++
  if(x1 > x2) x1--
  if(y1 < y2) y1++
  if(y1 > y2) y1--
  // add new y1 x1 to selected
}
```

#### Real-Time Word Highlighting
Another amazing new feature I added was highlighting as you type. The code for this is a simple depth-first search, except that instead of searching it adds every valid visited node as selected.
```js
function depthFirstSearch(grid, word, pos, index, past) {
  index = index || 0
  past = past || []
  if (!word[index]) return past
  var currentLetter = grid[pos]
  // visiting a previous node or out of bounds
  if (pos < 0 || pos > grid.length ||
    _.contains(past, pos) ||
    word[index] !== currentLetter)
    return []

  // cardinal directions (N,S,E,W) + diagonals (NW, NE, SW, SE) in 1D
  var dirs = _.filter([-5, -4, -3, -1, 1, 3, 4, 5], function (dir) {
    var col = pos % 4
    if (col === 0 && _.contains([-1, 3, -5], dir)
      return false
    if (col === 3 && _.contains([-3, 1, 5], dir)
      return false
    return true
  })

  // recurse
  return _.map(dirs, function (dir) {
    return depthFirstSearch(grid, word, pos + dir, index + 1, past.concat(pos))
  })
}
```

#### Minification and Concatenation
For any production application, minifying and concatenating JS source is essential for an optimal user experience. To automate the process, I used Grunt which is an amazingly powerful tool for running a multitude of tasks.
```js
module.exports = function(grunt) {

  grunt.initConfig({
    concat: {
      lib: {
        // order matters because jQuery needs to come before angular
        src: ['public/lib/*.js', 'public/lib/angular/**/*.js'],
        dest: 'public/dist/lib.js'
      },
      zoggle: {
        src: ['public/js/**/*.js'],
        dest: 'public/dist/zoggle.js'
      }
    },
    ngmin: {
      zoggle: {
        src: ['<%= concat.zoggle.dest %>'],
        dest: 'public/dist/zoggle.ngmin.js'
      }
    },
    uglify: {
      lib: {
        options: {
          sourceMap: 'public/dist/lib.js.map',
          sourceMappingURL: 'dist/lib.js.map',
          sourceMapPrefix: 1
        },
        files: {
          'public/dist/lib.min.js': ['<%= concat.lib.dest %>']
        }
      },
      zoggle: {
        options: {
          sourceMap: 'public/dist/zoggle.js.map',
          sourceMappingURL: 'dist/zoggle.js.map',
          sourceMapPrefix: 1
        },
        files: {
          'public/dist/zoggle.min.js': ['<%= ngmin.zoggle.dest %>']
        }
      }
    }
  });

  grunt.loadNpmTasks('grunt-contrib-uglify');
  grunt.loadNpmTasks('grunt-contrib-concat');
  grunt.loadNpmTasks('grunt-ngmin');

  grunt.registerTask('default', ['concat', 'ngmin', 'uglify']);

};
```
And set this in package.json to use grunt on Heroku:
```js
"scripts": {
  "postinstall": "echo postinstall time; ./node_modules/grunt-cli/bin/grunt"
}
```
A few things to note though. AngularJS injection relies on the variable names in functions. These change during compression, which is why it is necessary to use [ngmin](https://github.com/btford/ngmin)&nbsp;to prepare AngularJS code for compression. Additionally, the Angular-Seed project adds unnecessary files under /lib which must be deleted. Minified code (.min.js) (and source maps) should never be committed to source (add them to .gitignore), and should always be generated at compile time (by Grunt). Oh, and AngularJS is picky about what order you need to include jQuery (before Angular), or you may get unexpected errors.

#### Android application
Originally the mobile application was simply a web-view which pointed to the website, but I wanted to add a message in case there was no internet access. I figured that using Cordova (PhoneGap) would make it simple. I was wrong, but in the future I will be able to do it in mere minutes. Read my previous post on how to take a webapp and turn it into a native android mobile application in 5 minutes.&nbsp;[http://www.zolmeister.com/2014/01/how-to-turn-webapp-into-native-android.html](http://www.zolmeister.com/2014/01/how-to-turn-webapp-into-native-android.html)

#### Bonus
Recall the touching function from above:
```js
function touching(x1, y1, x2, y2) {
  return _.some(_.filter(_.flatten(_.map(_.range(-1,2),_.compose(_.partial(_.zip,_.range(-1,2)),_.partial(_.compose(_.partial(_.map,_.range(3)),_.partial),_.identity))),!0),_.compose(_.first,_.compact)), function(dir) {
    return x1+dir[0] === x2 && y1+dir[0] === y2
  })
}
```
For fun, I decided to write a functional-only (using only LoDash functions) generator for the 8 cardinal directions (2D) - N, S, E, W, NW, NE, SW, SE. That list ([[0,1],[0,-1],[1,0],[-1,0],[-1,1]...]) is what populates 'dir' in the function call. Let's see how I composed it:
```js
// Here is the original
var dirs = _.filter(_.flatten(_.map(_.range(-1,2),_.compose(_.partial(_.zip,_.range(-1,2)),_.partial(_.compose(_.partial(_.map,_.range(3)),_.partial),_.identity))),!0),_.compose(_.first,_.compact))

// Now let's decompose it

// [-1, 0, 1]
var oneDimention = _.range(-1,2)

// this first one is probably the most difficult to understand
// n -> [n, n, n]
var repeat3 = _.partial(_.compose(_.partial(_.map, oneDimention),_.partial),_.identity)

// n -> [[n, -1], [n, 0], [n, 1]]
var addToEachDimention = _.compose(_.partial(_.zip, oneDimention), repeat3)

// create a 3d matrix by joining 3x1 * 1x3 matrix
// [ [[-1, -1], [-1, 0], [-1, 1]], [[0, -1], [0, 0], [0, 1]], [[1, -1], [1, 0], [1, 1]] ]
var created3D = _.map(oneDimention, addToEachDimention)

// flatten
// [ [-1, -1], [-1, 0], [-1, 1], [0, -1], [0, 0], [0, 1], [1, -1], [1, 0], [1, 1] ]
var created2D = _.flatten(created3D, !0)

// removes [0, 0] from list
//[ [-1, -1], [-1, 0], [-1, 1], [0, -1], [0, 1], [1, -1], [1, 0], [1, 1] ]
var removedCenter = _.filter(created2D, _.compose(_.first,_.compact))
```
