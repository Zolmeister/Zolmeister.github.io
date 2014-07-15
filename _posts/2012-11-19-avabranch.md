---
layout: post
title:  "Avabranch"
date:   2012-11-19
---

**_[Avabranch](http://avabranch.zolmeister.com/)_**

[Avabranch](http://avabranch.zolmeister.com/)&nbsp;([source on Github](https://github.com/Zolmeister/avabranch)) is my entry for the [github gameoff](https://github.com/blog/1303-github-game-off)&nbsp;web-game challenge. It's built using [Node.js](http://nodejs.org/) and the [Express](http://expressjs.com/) framework, though most of the code is pure handwritten&nbsp;client-side&nbsp;javascript. I really enjoyed working on avabranch and wanted to take you through what I did to build it.

First of all, since the game uses canvas, we need to figure out how to clear, update, and draw our objects on the canvas. This is where 'requestAnimFrame' comes in. The boilerplate code for this function is this (it adds support for browser-specific implementations because it's not a finalized standard yet):

```js
window.requestAnimFrame = (function () {
  return window.requestAnimationFrame || window.webkitRequestAnimationFrame || window.mozRequestAnimationFrame || window.oRequestAnimationFrame || window.msRequestAnimationFrame || function ( /* function */ callback, /* DOMElement */ element) {
    window.setTimeout(callback, 1000 / 60)
  }
})()
```

Before we call this function however, we need to add things that need to be drawn. For me, I add a player, enemy spawner, hud, and powerup spawner to the game object, and then call the update function on the game object.

```js
function startGame() {
  keyListeners = []
  game.play = false
  game = new Game(canvas)
  var player = new Player(game, null, null, null, game.speed)
  var spawner = new BlockSpawner(game, game.speed)
  var hud = new HUD(game)
  var power_spawner = new PowerupSpawner(game)
  game.addObject("spawner", spawner)
  game.addObject("player", player)
  game.addObject("power_spawn", power_spawner)
  game.addObject("hud", hud)
  game.update()
}
```
Now, when I call game.update(), it runs this code:

```js
this.update = function (time) {
  if (!this.play) return;
  this.timeDelta = time - this.prevTime
  this.prevTime = time
  if (isNaN(this.timeDelta)) {
    requestAnimFrame(this.update.bind(this))
    return
  }
  this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height)
  this.physics(this.timeDelta)
  this.draw()
  requestAnimFrame(this.update.bind(this))
}
```
This is where most new developers make a mistake, as they forget the critical 'time' variable that is passed into the function by requestAnimFrame, which is essential for consistent playback across all machines. In order to make sure that a slow machine, unable to run the game at the optimum 60 fps, doesn't end up playing a game that runs half as fast we must keep track of how much time has passed since we last updated the objects on the screen. This is what 'timeDelta' is for, as it keeps track of this time. Now when the Game object calls the 'physics' function on all of its children, it passes in this timeDelta value which is used in the update code for objects that move. For example the 'Line' object uses timeDelta when it updates its position:

```js
this.points[i].y += .05 * timeDelta * this.ySpeed
```
Another thing that is important for gameplay is managing key state and key events. I actually ended up writing my own key event system for this. The basics of how I manage the keyboard are that I store all pressed keys in a JSON object, and on keypress I loop through any listeners that were listening for that keypress and run whatever function they passed in. Here is the code for that (the keys are converted from key number to letter for access in the dictionary):

```js
var keyListeners = []
var keyState = {};
var keyMap = {
  13: 'enter',
  37: 'left',
  38: 'up',
  39: 'right',
  40: 'down',
  186: ';'
};
window.onkeydown = function (e) {
  try {
    keyState[keyMap[e.which] || String.fromCharCode(e.which)] = e.which;
  } catch (e) {
    console.log('error converting keypress to char code')
  }
}
window.onkeyup = function (e) {
  try {
    delete keyState[keyMap[e.which] || String.fromCharCode(e.which)];
  } catch (e) {
    console.log('error deleting keypress to char code')
  }
}
window.onkeypress = function (e) {
  for (var i = 0; i < keyListeners.length; i++) {
    var k = keyMap[e.which] || String.fromCharCode(e.which)
    if (keyListeners[i][0] === k) {
      e.preventDefault()
      keyListeners[i][1]();
    }
  }
}
```

The last thing I want to mention is the code that I used to draw the lines. At first my approach was to draw a ton of dots as fast as I could to make it seem linear. This worked but was too CPU intensive, so I decided to try and come up with a better way to do it. I found out that you can draw lines on the canvas easily, and better yet it&nbsp;natively&nbsp;supports rounded caps. The problem was that before when you turned it was smooth, but now the&nbsp;edges&nbsp;were sharp. I tried to solve this by keeping track of the slope of the line, and when the slope changed then I would use the canvas 'quadraticCurveTo' method to round out the corner. This did not work well and so I continued to look for a solution. Turns out that canvas also lets you set the line joint type to round. Yeah, that was quite a journey, but I'm happy I got it working the way I wanted to. Here is the code:

```js
this.draw = function (ctx) {
  var tail = this.points[0]
  var head = this.points[this.points.length - 1]
  if (!tail || !head) return
  ctx.beginPath();
  ctx.lineWidth = head.r * 2
  ctx.lineCap = 'round'
  ctx.lineJoin = 'round'
  ctx.moveTo(tail.x, tail.y);
  ctx.strokeStyle = tail.color
  for (var i = 1; i < this.points.length; i++) {
    var point = this.points[i]
    ctx.lineTo(point.x, point.y)
  }
  ctx.stroke();
  ctx.closePath()
}
```
