---
layout: post
title:  "Fuco - A Coloring Game"
date:   2014-09-01
---

[![fuco](/assets/images/fuco_logo.png)](http://fuco.zolmeister.com)

[Web](http://fuco.zolmeister.com/) |
[Android](https://play.google.com/store/apps/details?id=com.zolmeister.fuco) |
[Chrome](https://chrome.google.com/webstore/detail/fuco/nknbogijbbpbhkfpojekilofmfbbmccj) |
[Amazon](http://www.amazon.com/gp/product/B00N0O21FU) |
[Firefox](https://marketplace.firefox.com/app/fuco/) |
[Source](https://github.com/Zolmeister/fuco)

Welcome, to Fuco ([Source](https://github.com/Zolmeister/fuco)),
a coloring game! Fuco was made in 48 hours as part of the
[Ludum Dare game compo](http://www.ludumdare.com/compo/ludum-dare-30/?action=preview&uid=29241).
The theme was `Connected Worlds`, which game me the inspiration for Fuco.
Originally I had an idea for a game that mixed game art styles (pixel art + isometric + full 3D),
however that was far too ambitious considering the time constraints and my artistic skills.

This was my second Ludum Dare, my first game being [Nent](http://zolmeister.com/2013/12/nent.html)
which took advantage of WebGL shaders for a metaballs effect. Since I [joined Clay.io](http://zolmeister.com/2014/07/cto-cofounder-clay-io.html)
I figured that this time I would make a game that could be played on mobile,
which meant no WebGL (due to iOS support). Because I wrote platform-agnostic code, I was easily able to publish the game to many platforms [using Cordova](http://zolmeister.com/2014/01/how-to-turn-webapp-into-native-android.html)

Being my second time participating I should have had better time management.
However I made most of the game on Sunday (pulling an all-nighter, being awake during the [earthquake](http://america.aljazeera.com/articles/2014/8/24/san-francisco-earthquake.html) at 3am):
[![timeline](/assets/images/fuco_github_timeline.png)](https://github.com/Zolmeister/fuco)

<iframe frameborder=0 src="http://fuco.zolmeister.com" style="width: 300px; height: 500px; margin: 0 auto"></iframe>
<br>

#### Negative coloring without shaders

When you play the game, you'll notice that coloring the correct area below will erase the
color above, and an incorrect coloration will override the above color (incorrectly).
Solving this problem in a performant way on HTML5 Canvas was not immediately obvious.
If I had been able to use WebGL, I could easily write a shader which could do calculations
based on each pixel value. However canvas is too slow to update each pixel each frame
which meant my solution had to be based on native canvas calls.


Each section of the circle is defined by a closed shape, so I simply erase
the region the player is brushing using `ctx.clip()` which allows me to mask draw calls.
Here is my solution:

```js
if (y < 0) {
  // erase inside selected brush clip region
  ctx.save()
  ctx.beginPath()
  region.path(ctx)
  ctx.clip()

  radgrad = ctx.createRadialGradient(x,y,brushSize/4|0,x,y,brushSize/2|0)
  radgrad.addColorStop(0, $white.toString())
  radgrad.addColorStop(0.9, $white.alpha(1).toString())
  radgrad.addColorStop(1, $white.alpha(0).toString())
  ctx.fillStyle = radgrad
  ctx.fillRect(x-brushSize/2|0, y-brushSize/2|0, brushSize, brushSize)
  ctx.fillRect(x-brushSize/2|0, y-brushSize/2|0, brushSize, brushSize)

  ctx.restore()
}
```

[![fuco](/assets/images/fuco_screenshot.png)](http://fuco.zolmeister.com)


#### Home screen animation

One of my favorite effects I made for this game was the home screen animation of the logo.
Some googling for SVG animation landed me at [this example](http://codepen.io/netsi1964/pen/iyglK),
which I adapted slightly for my purposes. I used Inkscape to draw the SVG paths,
and them inlined the SVG into the HTML.

```js
var $paths = document.getElementsByTagName('path')

// This is hard coded because it crashes android if you calculate it
var pathLengths = [114.63752746582031, 135.55255126953125, 115.6463851928711, 147.36000061035156, 3442.748291015625, 1806.394775390625, 8450.58984375, 8450.58984375]
window.addEventListener('load', function () {
  var i = $paths.length
  while(i--) {
    // This line will crash android browser clients
    // pathLengths[i] = $paths[i].getTotalLength()
    simulatePathDrawing($paths[i], i)
  }

  document.body.style.visibility = 'visible'
})

function simulatePathDrawing(path, i) {
  var length = pathLengths[i]
  path.style.transition = path.style.WebkitTransition = 'none';
  path.style.strokeDasharray = length + ' ' + length
  path.style.strokeDashoffset = length
  path.getBoundingClientRect()
  path.style.transition = path.style.WebkitTransition = 'stroke-dashoffset 1.25s ease-in-out'
  path.style.strokeDashoffset = '0'
  path.style.strokeWidth = '2px'
}

```
