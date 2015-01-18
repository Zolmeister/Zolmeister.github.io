---
layout: post
title:  "戦士 - Senshi (an MMO Battle-Royale inspired game)"
date:   2013-09-08
---

[![](http://1.bp.blogspot.com/-j5eG97sWxOI/Uizyu9QnYkI/AAAAAAAAAoM/3hFSoyaRn5s/s640/Selection_029.png)](http://senshi.zolmeister.com/)
#### [senshi.zolmeister.com](http://senshi.zolmeister.com/)
A real-time MMO Battle-Royale inspired game, with permadeath (names can never be reused).
Source:&nbsp;[github.com/Zolmeister/senshi](https://github.com/Zolmeister/senshi)&nbsp;-&nbsp;Sprite Attribution: [Ghosa](http://opengameart.org/content/18x20-characters-walkattackcast-spritesheet)
Audio editor:&nbsp;[senshi.zolmeister.com/audio.html](http://senshi.zolmeister.com/audio.html)

This game is my submission to [js13kgames](http://js13kgames.com/), a contest similar to [js1k](http://js1k.com/), but instead you get 13k (for the client, and also the server), and you get to zip it (!). After competing in js1k, I was amazed at how much I could get out of 13k, especially due to the zipping. In fact, the source in the zip files is uncompressed, because using a minifier actually increased the file size. In the end: client - 11.3KB, server - 4.1KB.

Making the game was fairly straight forward, except perhaps the audio, which I will explain in detail, as well as the real-time socket.io code.

The game engine is completely server-side, with the client solely used for rending and sending keystrokes. This is necessary to prevent cheating, as the client can never be trusted. The ideal solution (which I didn't get around to implementing) is to have the client and the server both have physics engines running simultaneously, with updates from the server forcing the client to sync up. Here is a great video from Google.IO which goes deep into the mechanics of a real-time MMO game:
[Google I/O 2012 - GRITS: PvP Gaming with HTML5](http://www.youtube.com/watch?v=Prkyd5n0P7k)
With the 13KB limitation, you have a lot of room to work with in terms of pure JS, however the art assets (Sprites and Audio) are highly constrained. For this reason, I decided to go with pixel art, and custom audio format. I am not the most artistically inclined person, so I opted to use a sprite someone else made on&nbsp;[opengameart.org](http://opengameart.org/)&nbsp;and then modified it to include each weapon (using [GIMP](http://www.gimp.org/)). Here is what my sprite sheet/atlas looked like:

[![](http://3.bp.blogspot.com/-P_TPHAlR2MU/Uiz3-CdE9GI/AAAAAAAAAog/iE5RKVK7iEg/s1600/player.png)](http://3.bp.blogspot.com/-P_TPHAlR2MU/Uiz3-CdE9GI/AAAAAAAAAog/iE5RKVK7iEg/s1600/player.png)

As you can see, each frame of animation has its own image, as well as each weapon. On the right, I merged the item/terrain atlas in the same PNG to save space. The player is 22x20px, and the items are 14x14px (some items were unused).

One of the biggest features I wanted to add was diagonal walking, but I just could not muster the artistic talent (not for lack of trying) to draw the character (lets call him Zed) facing new directions. So I cheated by skewing the image using ctx.setTransform() :

```js
function drawPlayer(x, y, name, health, dir, frame, weapon, kills) {

  // 22 x 20, with +10 x-offset
  var tanAngle = Math.tan(Math.PI / 4)
  var rowDir = [1, 0, 0, 0, 1, 2, 2, 2]
  var row = rowDir[dir]
  var col = frame == 3 ? 1 : frame
  col += (weapon + 1) * 7
  x += 10

  ctx.save()
  if (dir == 0 || dir == 1 || dir == 7) {
    // facing left
    ctx.translate(44, 0)
    ctx.scale(-1, 1)
    x = 22 - x
  }

  //draw character
  ctx.translate(x+11,y+10)

  if (dir%2==1) {
    // diagonal
    if(dir==1 || dir==7)
    ctx.setTransform(3.8, (dir == 1 || dir == 5 ? -1 : 1) * tanAngle, 0, 4, 400-x*4+22*4+11*4, 300+y*4+10*4)
    else
      ctx.setTransform(3.8, (dir == 5 ? -1 : 1) * tanAngle, 0, 4, 400+x*4+11*4, 300+y*4+10*4)
  }

  ctx.drawImage(image, col * 22, row * 20, 22, 20, -11, -10, 22, 20)
  ctx.restore()

}
```
Another thing to note is that I was unable to use off-screen [canvas pre-rendering](http://www.html5rocks.com/en/tutorials/canvas/performance/)&nbsp;because It kept [aliasing](http://en.wikipedia.org/wiki/Aliasing) the image, event through I told it not to (a big problem for a pixel-art game):

```js
ctx.webkitImageSmoothingEnabled = false
ctx.mozImageSmoothingEnabled = false
```
In order to get some real-time action going, I decided to use [Socket.io](http://socket.io/) (as it is allowed by the rules without counting against the file-size). Socket.io is a [Websockets](http://www.html5rocks.com/en/tutorials/websockets/basics/) compatibility library which uses backup transports for data if websockets is not available (Socket.io is absolutely amazing!). Now, notice that the player has a lot of attributes associated with them: name, x, y, health, kills, weapon, direction, animation frame, isAttacking, and the keys that they are pressing (remember, everything is computed server-side). Every tick of the physics engine, we have to update all the users positions and send the data out to all the other players. This adds up to a lot of data being sent, and exponentially increases per-player in the arena.

In order to be efficient with how much data we send per player, I decided to only send a `diff`, or only what has changed in game state since the last update. I shrunk all variable names to 1 letter, and devised a data structure that would efficiently provide a full diff. Here is what I came up with (small snippet):

```js
// This diff will be sent and applied by the client to sync their arena
// diff[0-2] = players
// diff[0] = new players (append to end)
// diff[1] = del players indicies (splice, starting in reverse order)
// diff[2] = player updates (i:index, updated attrs)
// diff[3-5] = bullets
// diff[6-8] = items
var diff = physics(++frame)

// don't send if empty
if (!diff.reduce(function (total, x) {
  return total + x.length
}, 0)) return

// clear out empty trailing arrays
var found = false
var i = diff.length - 1
while (diff[i] && diff[i].length == 0) {
  diff.splice(i, 1)
}
```
This added a lot of serialization/deserialization overhead, however it was worth it because it drastically reduced data size. After setting up a diff-based structure, I decided to look into more ways of data compression. This website was quite helpful:&nbsp;[buildnewgames.com/optimizing-websockets-bandwidth/](http://buildnewgames.com/optimizing-websockets-bandwidth/). Additionally, I found this tool which looked quite promising:&nbsp;[msgpack](http://msgpack.org/). Basically it defines a way to represent JSON as binary data in a highly optimized way. Sadly, I was unable to use it, not because of it's filesize, but for lack of binary data support in Socket.io -&nbsp;[#511](https://github.com/LearnBoost/socket.io/issues/511). Socket.io isn't perfect, but I was disappointed in that it didn't support some of the really useful data compression options available to raw websockets - [#1148](https://github.com/LearnBoost/socket.io/issues/1148), [#680](https://github.com/LearnBoost/socket.io/issues/680).

In the end, I went with the diff strategy, which will hopefully be enough (haven't tested at large scale).

The last significant part of this game is the audio. Now, let me preface by saying that I made the audio myself, with no help, and zero prior experience. That being said, I think the audio actually turned out pretty good. Not great, but pretty good. Also, the audio data size (with decoder) ended up being ~1.3KB, which is outstanding considering that even the most trivial music goes into the hundreds of KB.

With only 13KB to work with, I looked at perhaps using someone else's music and just [bitcrushing](http://en.wikipedia.org/wiki/Bitcrusher) it. However, it quickly became apparent that I wasn't going to get enough length and quality out. So I decided to look at what others had done, and found this amazing resource: [Chime Docs](http://games.23inch.de/chime/doc/) ([Chime Hero](http://js1k.com/2012-love/demo/1265)). I also found this great tutorial on [`chipping` techniques](http://www.milkytracker.org/docs/Vhiiula-TechniquesOfChipping.txt) (for creating [Chiptunes](http://www.youtube.com/results?search_query=chiptunes) - classic 8-bit music). Based on this information, I decided to make my own chiptunes editor:&nbsp;[senshi.zolmeister.com/audio.html](http://senshi.zolmeister.com/audio.html)

The editor is basic, and quite limited in what you can do, but it gets the job done. The key though, is that it is able to output algorithmically compressed audio, which leads to a 1 minute song at &lt;1.5Kb.
In order to create the editor I followed the Chime Hero docs carefully, and from it figured out how to generate all of the other types of sound waves (this fiddle was also helpful: [jsfiddle.net/CxPFw/1](http://jsfiddle.net/CxPFw/1/)):

```js
var samples = Math.floor(11025 / 2)
var bytes = []
for (var s = samples; s--;) {
  var byte;
  if (note.wave === 'square') {
    /* Square wave */
    byte = (Math.sin(s / 44100 * 1 * Math.PI * note.freq) > 0 ? 1 : -1)
  } else if (note.wave === 'sine') {
    /* sine wave */
    byte = Math.sin(s / 44100 * 2 * Math.PI * note.freq)
  } else if (note.wave === 'saw') {
    /* sawtooth wave */
    byte = sawtooth(s / 44100 * note.freq)
  } else if (note.wave === 'ramp') {
    /* ramp wave */
    byte = Math.abs(s % (note.freq) - note.freq) / note.freq
  }
   bytes.push(byte)
}

bytes = bytes.map(function (byte, s) {
  s = samples - s
  // normalize bytes
  return byte * 127 + 128
}).reduce(function (str, byte) {
  // encode the bytes
  return str + String.fromCharCode(byte);
}, '')

var player = new Audio('data:audio/wav;base64,UklGRjUrAABXQVZFZm10IBAAAAA\
   BAAEARKwAAESsAAABAAgAZGF0YREr' + btoa('\9\0' + bytes))
player.play()

function sawtooth(x) {
  var pi = Math.PI
  var tn = Math.ceil((x + pi) / (2 * pi));
  var y = ((x - tn * 2 * pi) + 2 * pi) / pi;
  return y
}
```
With this code, I am able to simply export an array of `[freq, wave]` date from the editor, and then convert that into music (highly efficient). Also for those astute musicians, I decided to use a D Minor Pentatonic scale for the note range, <del>using this [scale hertz chart](#null) as reference</del>.

Now, if you hit the 'export' button in the editor, you may note that the output string in the console is actually ~12KB. This is because while the data is highly optimised, it is not yet compressed. For that, we go to [JSCrush](http://www.iteral.com/jscrush/)&nbsp;which compresses javascript by turning it into a string, and then compressing that string via pointers to heavily used sequences within the string. It does a fantastic job of compressing the output to a manageable size.

Now, after loading that code into the game, I realized that the compile time (to generate the wave from frequency data) was quite long and blocked the UI, so I decided to offload it to an embedded [Web Worker](https://developer.mozilla.org/en-US/docs/Web/Guide/Performance/Using_web_workers)&nbsp;(The 'export' globalizes an 'a_audio' object which is the un-base64 encoded data string seen in the above code as 'bytes'):

```js
<script id='audioworker' type='text/js-worker'>
_='  keW  t(eWvar t=<PI;var n=<ceil((e+t)/(2*t));var r=(e-n*2*t+2*t)/t; r}`=<floor(11025/2); s=e!nWj=nNeW=[]e[1];&=e[0]; =0;Bif==01>0?1:-1$=12$2W =tO&)$3W =<abs(Fs%&-&)/&}.push( )} })!tW tNt,nW e[n]?[t].concat(e[n]):[t]})},[])NeW e!tW e+t},0)/e})Ne,tWt=`-t; e*127+128})!tW e+Gt)},"");if(j===0WBj+=G128)}} e+j},"");Faudio="9\\0"+ s}Fr=[[  |K  |J  |D  |J  |K  |  1XXXX  KZ           Z[ 1  L   RK D  RJ  RK  z,R  R   LH          Y     T T T                Q   [ @ T @ T @   @ Q   Y             @ T @ T @  LLKZ    J1  D1   JZKZ   1  DZ    JZDZH   Q LL [z   @ T @   @^,TL ]];kFr)   2  R JZDZ  ,@ 3 z,R ],[ ~, U3, V3, [^, [z, 174.61, J1 D1 [^ #3 @440 @V# @U3 [ @^  0  1  1  DZ T[ 392, KZJZ  z, RJ  RD  R  R function Fbyte 440, return   [ ]        T T T       [   1 [  ^,   [z [^ [U3 [~ [V3  !.reduce( (e,#3  @~ $}else if=&Ffreq<Math.@0 Bfor(Fs=`;Fs--;WD[   Fa_GString.fromCharCode(H[      J   K   L    N.map( (O(Fs/44100*Q      R3 T  U261.6V349.2W){X      Y                Z1 ^220`FsamplesjFtonekplayExported(z196|1  ~293.6Fwave= [ @392 [[            sArr     W =<sinO       ZT @ T @  @U#[ @V        .length*<PI*&)[     RR ^,RK        ';for(Y in $='~|zkj`^ZYXWVUTRQONLKJHGFDB@<&$#!                             ')with(_.split($[Y]))_=join(pop());eval(_)

postMessage({'setAudio': a_audio})
</script>
```
($ is not jQuery, instead it uses the built-in selector: `$ = document.querySelector.bind(document)`)

It's worth noting that there is still some lag due to the creation of the audio element, which you can't offload to the Web Worker because it doesn't have access to the `Audio()` object, or the `btoa` function for that matter ([#55663](https://bugs.webkit.org/show_bug.cgi?id=55663)).