---
layout: post
title:  "The Pond at Mobile World Congress with Firefox OS"
date:   2014-03-04
---
[<img src="http://2.bp.blogspot.com/-yLV0_IB2btc/UxVqdiPpSQI/AAAAAAAACZA/tFAbgWeJj_E/s1600/ffos-booth.jpg" style="max-width: 600px;">](http://2.bp.blogspot.com/-yLV0_IB2btc/UxVqdiPpSQI/AAAAAAAACZA/tFAbgWeJj_E/s1600/ffos-booth.jpg)

Last week I attended [Mobile World Congress](http://www.mobileworldcongress.com/) in Barcelona, Spain after being invited by Mozilla to show off [The Pond](http://thepond.zolmeister.com/) ([blog post](http://www.zolmeister.com/2013/10/the-pond.html)). Originally Mozilla found me through my blog, and asked me to write a post about [The Pond on Mozilla Hacks](https://hacks.mozilla.org/2013/11/the-pond-building-a-multi-platform-html5-game/). For Mobile World Congress they were looking for app developers to help showcase [Firefox OS](http://www.mozilla.org/en-US/firefox/os/), which is where I came in.

Before heading out though, I decided to update the app in a few areas:

#### Memory Management Update
The first thing I looked at was memory management, and attempted to [achieve static memory](http://www.html5rocks.com/en/tutorials/speed/static-mem-pools/) via object pooling. Unfortunately things didn't go smoothly, though decreasing allocations inside core inner loops aided greatly in reducing the rate at which the garbage collector ran.

![](http://2.bp.blogspot.com/-BzPPfLE2g1E/UxVzSkY-uXI/AAAAAAAACZQ/Ut9sna2USVo/s1600/Selection_089.png)


#### Device Scaling via devicePixelRatio
If you're not familiar with mobile web, the following meta tag is used to properly scale websites:

```html
<meta name="viewport" content="width=device-width,user-scalable=no">
```

However, the problem with this approach is that it scales the canvas as well, causing the rendering to be low resolution. The solution is to scale the canvas size relative to the device pixel ratio, increasing the rendering resolution without changing the physical size of the canvas:

```js
devPixelRatio = window.devicePixelRatio || 1
$canvas.width = window.innerWidth * devPixelRatio
$canvas.height = window.innerHeight * devPixelRatio
ctx = $canv.getContext('2d')
```

Background Music
A while back I created a game called [Avabranch](http://avabranch.zolmeister.com/), wherein I used a background sound track I found on [Sound Cloud](https://soundcloud.com/). The author of that track, [Chrissi Jackson](https://soundcloud.com/chrissij), got in touch with me and offered to create an audio track for The Pond. She did a fantastic job, and got it to me just in time, with the commit going in less than 3 hours before the conference.

<audio controls="controls" src="http://thepond.zolmeister.com/assets/bg.ogg"></audio>


Mobile World Congress
Surprisingly, the vast majority (I'd say ~90%) of attendees were business people and not developers. Even more surprising was the crazy world of meetings which manifested itself at the conference by means of physical meeting rooms. The first hall was entirely dedicated to meeting rooms, and more were spread out throughout the rest of the halls. That being said, I personally got to speak with some amazing people, including the guy behind [js13k games](http://js13kgames.com/) (for which I wrote [Senshi](http://www.zolmeister.com/2013/09/senshi-mmo-battle-royale-inspired-html5.html)), someone from [Aviary](http://www.aviary.com/), and a few people from [Line](http://line.me/en/).

Many people were interested in The Pond, which I demoed for those that came to the Firefox OS booth. Additionally, I got to show a few people [Zoggle](http://www.zolmeister.com/2014/01/zoggle-rewritten-using-angularjs.html), and got some great responses (Spanish Zoggle might be coming soon!). Overall most people seemed to enjoy the games and were really interested in the technology behind them.

There were also a few interesting products at MWC, including some [Tizen](https://www.tizen.org/) and [Ubuntu mobile](http://www.ubuntu.com/phone) devices and a handful of smart watches which were fun to play with. However, both were trumped by the recently announced [$25 Firefox OS phone](http://reviews.cnet.com/8301-13970_7-57619338-78/with-firefox-os-mozilla-begins-the-$25-smartphone-push/) (which I tested out). The potential impact of the phone is huge, and look forward to the challenge of developing for such a low-end device.
Barcelona

And finally I also got to spend some time exploring the beautiful city of Barcelona:  
<img src="http://2.bp.blogspot.com/-zNUgYc9KmIY/UxWB3ydhYAI/AAAAAAAACZg/zl9l8DD9mlg/s1600/IMG_20140225_122545.jpg" style="max-width:500px">
<img src="http://1.bp.blogspot.com/-T0V6WO9TU-U/UxWB4HjY4sI/AAAAAAAACZk/6CmSqRvnDQE/s1600/IMG_20140225_131112.jpg" style="max-width: 500px">
