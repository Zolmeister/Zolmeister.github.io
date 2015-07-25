---
layout: post
title:  "How not to write a massively multi-player game"
date:   2012-09-08
---


<br>
#### Welcome to Page Explorer!
<del>Click here to join!</del>&nbsp;(no longer up)  
<del>Click here&nbsp;(again)&nbsp;to join! (yes, bug)</del>  
Now hit the CAPS LOCK key (to toggle view state)  
After you have joined here are the controls:

[![](http://1.bp.blogspot.com/-254J_x8iPIU/UEwu6X5yYHI/AAAAAAAAAVo/epFhspyE52c/s1600/page-explorer-dude.png)](http://1.bp.blogspot.com/-254J_x8iPIU/UEwu6X5yYHI/AAAAAAAAAVo/epFhspyE52c/s1600/page-explorer-dude.png)

*   Ctrl = Jump
*   arrow keys = move
*   Down = Descend a level
*   Ctrl + up = pull up
*   CAPS LOCK = toggle game (visible/hidden)
*   T = chat (just start typing and the text will appear top-left, then enter to submit)

Want to explore&nbsp;somewhere&nbsp;else? Drag this link: <del>Page Explorer</del> to your bookmarks bar, then click on it when your on the site you want to join (may have to click it twice, also chrome blocks it in https pages).
"Wow this is so cool! How can I get the source?" - on [github](https://github.com/Zolmeister/Page-Explorer)!
Alright, lets break it down!
A few words of warning before I begin, this game is one of my most poorly written and broken games of all. This was a great learning experience in what not to do with a game, and I hope that you will learn something too.

First let me explain how this app works on a general level.</div><div>

1.  User injects script onto page
2.  script loads all the assets
3.  all assets load
4.  script connects using [Socket.io](http://socket.io/) to the master [Node.js](http://nodejs.org/) server
5.  The server puts the user in a room based on the website they're on
6.  users position, name, and animation state are sent to the server
7.  server relays info to all clients in room
8.  GO TO 6

This part actually makes sense, and what makes Page Explorer cool is that you can run it on any page you want. This also happens to be what makes it fail, due to different page layouts of the same site from different users makes them appear to float in mid air and other such bugs which are largely out of my control.

Ok lets start at the beginning of the code (or rather the first part that I wrote and where things wen't horribly wrong). I decided to write a skeletal animation system. Those look like this:
[![](http://animadead.sourceforge.net/images/selection.gif)](http://animadead.sourceforge.net/images/selection.gif)
Basically a bunch of nodes connected to each other. This allows me to draw the player once and animate him freely. If you're confused, this video might help:&nbsp;[http://www.youtube.com/watch?v=34cBGjCKkgU](http://www.youtube.com/watch?v=34cBGjCKkgU)

The issue here is that everything is absolute positioned instead of being relative to one another. The correct way to do it would have been to use a [Polar system](http://en.wikipedia.org/wiki/Pole_and_polar) (angle, distance) instead of a&nbsp;[Cartesian&nbsp;system](http://en.wikipedia.org/wiki/Cartesian_coordinate_system) (x,y).

```js
var skeleton = [{
 "name": "root",
 "rot": 0,
 "x": 279,
 "y": 266,
 "skin": {},
 "parent": -1,
 "id": 0,
 "children": [6, 7, 8]
}, {
 "name": "head",
 "rot": 0,
 "x": 282,
 "y": 150,
 "skin": {
   "self": {
     "name": "head",
     "x": 0,
     "y": -20
   },
   "bone": "neck"
 },
 "parent": 6,
 "id": 1,
 "children": []
}, ...
```
My next step was creating an editor, in order to create everything (ie, draw the bones and connections and add skins etc.). Problem was that I was lazy. I ended up **hard-coding the base skeletal system** and the animation system involved saving a skeletal state to localstorage when done. There was no "undo" button, and I&nbsp;couldn't&nbsp;edit multiple animations at a time. To get it into my code I copy pasted the giant list of skeletal positions into my source. This is where spending just a bit more time in creating a good editor would have saved me tons of work. (I could post the source for my editor but i'd rather not... it's hideous).

My next mistake was in&nbsp;separating&nbsp;the user (you) from everybody else. I had to **duplicate everything** (physics, drawing, etc) in my code (that's bad - never duplicate code).&nbsp;This also caused me to keep all of the game code related to the player in one file (main.js - **651** lines) and then duplicate it in another file (socket.js - **173** lines). Yes, main.js should not contain all the code that it does and it was an absolute pain to debug.

My animation sequence seems ok at first, but it is definitely broken. Here is what it looks like:

```js
function movePlay() {
  if (playQueue.length < 2) {
    playing = false;
  } else if (sameFrame(playQueue[1], playQueue[0])) {
    playQueue.splice(0, 1);
    updatedQueue();
  } else {
    for (var i in playQueue[0]) {
      var curS = playQueue[0][i];
      var tarS = playQueue[1][i]; //have to align within 60 frames
      var xDistance = curS.x - tarS.x;
      var yDistance = curS.y - tarS.y;
      var rotDistance = curS.rot - tarS.rot;
      var framesLeft = 10 - currentFrame % 10;
      if (curS.x != tarS.x) curS.x += xDistance / framesLeft * -1;
      if (curS.y != tarS.y) curS.y += yDistance / framesLeft * -1;
      if (curS.rot != tarS.rot) curS.rot += rotDistance / framesLeft * -1;
      if (framesLeft < 1) {
        curS.y = tarS.y;
        curS.x = tarS.x;
        curS.rot = tarS.rot;
      }
    }
  }
}
```
The basis for this animation function is that it takes at least 2 frames (states of skeletons) and then motion-tweens them by one step when it's called. The issue (if it wasn't obvious) is that it doesn't support speed-change in tweens. This means that lets say I wanted the player to punch really fast (1 frame fist back, next frame fist forward), it would play really slow because my play-rate (10 steps - **var framesLeft=10-currentFrame%10;**) is constant. From one frame to the next is always the same amount of time. Instead, it should be set by the editor and be a value in the animation sequence (# steps the animation should take).

Another issue (which I didn't realize till too late) was my abundant use of global variables (maybe my&nbsp;separate&nbsp;var.js file should have given me a hint).

```js
player.height = 500;
player.width = 500;
var playC = player.getContext("2d");
var selectedBone;
var assetsList = ["head", "left arm", "left foot", "left forearm", "left hand",
     "left leg", "left thigh", "neck", "right arm", "right foot", "right forearm",
     "right hand", "right leg", "right thigh", "spine", "joint", "joint2", "none",
     "hat1", "hat2", "hat3", "hat4", "hat5", "hat6"];
var keysPressed = [];
var assetCount = 0;
var assetCallback;
var assets = {};
var playQueue = [];
var name = localStorage.name || prompt("name?");
localStorage.name = name;
var chats = [];
var hidden = true;
var chatting = false;
var currentChat = "";
var passingThrough = false;
var others = {};
var myHat = Math.floor(Math.random() * 6) + 1
var bgCtx = bgCanvas.getContext("2d");
var currentFrame = 0;
var locked = false;
var showBone = false;
var jumping = true;
var climbing = false;
var grav = 1;
var deltaTime = 0;
var blocks = [];
var lastTimestamp = Date.now();
var me = {
  x: 0,
  y: 0,
  width: 100,
  height: 100,
  dir: "right"
}
```
The solution to this is simple enough. I should have created a Game class which had these values associated with it, as well as&nbsp;separating&nbsp;values that control game state (ie. passingThrough, chatting, hidden etc.) from values controlling player state (jumping, climbing etc.).

Well, I hope that you found something useful in all that I did wrong. Bottom line is **Don't Half-Ass Your Code**. Do it right from the start (never say "I'll fix it later" or "I'll get back to it eventually" - especially in the&nbsp;beginning).

Cheers!
