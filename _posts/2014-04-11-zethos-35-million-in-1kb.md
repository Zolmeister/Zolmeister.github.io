---
layout: post
title:  "Zethos - $3.5 million in 1kb"
date:   2014-04-11
---
[<img src="http://4.bp.blogspot.com/-fwxtkVefC2w/Ux0xB0zKv_I/AAAAAAAACcY/v4-MYpaENck/s1600/Selection_090.png" style="max-width: 600px">](http://zethos.zolmeister.com/)

[Zethos](http://zethos.zolmeister.com/) is my $3.5 million dollar entry to [js1k 2014](http://js1k.com/2014-dragons/). It's a speed reading tool, allowing almost anyone to read at 500 words per minute (the average person reading 250wpm [[1]](http://en.wikipedia.org/wiki/Speed_reading)). By keeping the text centered within the readers view, the reader is able to reduce costly eye movements and increase their reading speed.

Zethos was inspired by [Spritz](http://www.spritzinc.com/), who recently raised a [$3.5 million seed round](http://techcrunch.com/2014/03/10/spritz-seed/) for their speed-reading technology. However their software is closed and their system is not developer friendly so I decided to make my own. Without further ado, here is what $3.5 million code looks like:

```js
parse = function(str) {
  // Logic
  // strings will be broken out into words
  // find the focus point of the word
  // if, when the word is shifted to its focus point
  //   one end prodtrudes from either end more than 7 chars
  //   re-run parser after hyphenating the words

  // focus point
  // start in middle of word (default focus point)
  // move left until you hit a vowel, then stop

  // hyphenating
  //    if <= 7 chars
  //      return self
  //    if <= 10
  //    return x, {3}
  //    if <= 14 chars
  //    return {7},{7}
  //    else
  //    return {7},hyphenated{x}

  hyphenate = function(str) {
    with(str)
    return length <= 7 ? str : length <= 10 ? slice(0,length - 3)+'- '+slice(length-3) : slice(0,7)+'- '+hyphenate(slice(7))
  }

  // return 2d array with word and focus point
  return str.trim().split(/[\s\n]+/).reduce(function(words, str) {
    with(str) {
      // focus point
      focus = (length-1)/2|0

      for(j=focus;j>=0;j--)
        if (/[aeiou]/.test(str[j])) {
          focus = j
          break
        }

      t = 60000/500 // 500 wpm

      if (length > 6)
        t+=t/4

      if (~indexOf(','))
        t+=t/2

      if(/[\.!\?;]$/.test(str))
        t+= t*1.5

      return length >= 15 || length - focus > 7 ? words.concat(parse(hyphenate(str))) : words.concat([[str, focus, t]])
    }
  }, [])
}

p = function() {
  index = 0
  input = parse(i.textContent);
  playing = !playing
  playing && loop()
}

loop = function() {
  w = input[index++] || p()
  o.innerHTML = Array(8 - w[1]).join('&nbsp;')+w[0].slice(0,w[1])+'<v>'+w[0][w[1]]+'</v>'+w[0].slice(w[1]+1)
  playing && setTimeout(loop, w[2])
}

p()
```
I've done [Javascript Golfing before](http://www.zolmeister.com/2012/06/javascript-golfing.html), so getting this code to fit in at less than 1kb was trivial. With the help of [Grunt](https://github.com/Zolmeister/zethos/blob/master/Gruntfile.js), I was easily able to compile my code by running it through the Google [Closure Compiler](https://developers.google.com/closure/compiler/) and then [JSCrush](http://www.iteral.com/jscrush/). They key to the code however is it's recursive nature. The self-calling methods allow the code to be extremely concise and not reliant on a buffer or global variables. The Hyphenate method for example will recursively hyphenate the word it's given based on length for arbitrarily sized words using recursion.

As far as implementation goes, the part that could be most improved for production applications would be to add proper hyphenation. There's a paper written about [algorithmic hyphenation](http://tug.org/docs/liang/liang-thesis.pdf), and even an [npm library](https://www.npmjs.org/package/hypher) to do this, however fitting it in 1kb was not feasible.

Lastly, my first js1k attempt this year did not work out. It was intended to be a neural network handwriting recognition engine ([TinyNet](https://github.com/Zolmeister/tinynet)), but unfortunately the weights of the network proved to be highly non-compressible.
