---
layout: post
title:  "Polish.js - Making JavaScript Better"
date:   2013-05-14
---

[![Polish.js](https://raw.github.com/Zolmeister/Polish.js/master/polish-logo.png "Polish.js")](https://github.com/Zolmeister/Polish.js)**[Polish.js](https://github.com/Zolmeister/Polish.js)**

JavaScript is pretty great, but it's not perfect. So I made it better by adding some extra functionality.
(note. I add 2 global functions, range and zip because they are amazing, but the rest is either scoped under the Polish namespace, or added onto the default object properties.)

#### Before:
```
     > Math.min([1,2,3])
     NaN
     > Math.randInt(2,10)
     TypeError: Object #<Object> has no method 'randInt'
     > range(1,5)
     ReferenceError: range is not defined
     > Math.sum([1,2,3])
     TypeError: Object #<Object> has no method 'sum'
     > [1,2,3][-1]
     undefined
```
#### After:
```
      > Math.min([1,2,3])
      1
      > Math.randInt(2,10)
      6
      > range(1,5)
      [1, 2, 3, 4]
      > Math.sum([1,2,3])
      6
      > [1,2,3][-1]
      3
     > list = [1,2,3,4,5]
     > list.pop(1) // pops index
     2
     > list.remove(2) // removes element
      [1,3,4,5]
     > list.insert(2,5)
     [1,2,5,3,4,5]
```
Now, those are just the basics. What would be really great is if we could utilize python selectors:
```
	> "abcdef".g('-3:-1')
     'de'
```
And wouldn't it also be great if we had access to some of the python itertools methods?
```
     Polish.combinations([1,2,3],2)
     Polish.combinationsReplace("abc",2)
     Polish.permutations([1,2])
```
[](http://www.blogger.com/)There are a few more goodies in there too, check out library on [GitHub](https://github.com/Zolmeister/Polish.js).
