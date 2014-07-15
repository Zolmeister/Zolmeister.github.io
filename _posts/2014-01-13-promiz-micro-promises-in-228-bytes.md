---
layout: post
title:  "Promiz Micro - Promises in 228 bytes (min+gzip)"
date:   2014-01-13
---

[![](https://raw.github.com/Zolmeister/promiz/master/imgs/logo.png)](https://github.com/Zolmeister/promiz)

[Promiz.js](https://github.com/Zolmeister/promiz) ([original post](http://www.zolmeister.com/2013/07/promizjs.html)) is a (now) completely [Promises/A+](http://promises-aplus.github.io/promises-spec/) spec compliant library that fits in 590 bytes (min+gzip). In addition, the new&nbsp;[Promiz Micro](https://github.com/Zolmeister/promiz#promiz-micro) comes in at 228 bytes (min+gzip) and provides an amazingly clean API.

#### Promiz Micro:

```js
!function(){function a(b,c){function d(a,b,c,d){if("object"==typeof h&&"function"==typeof a)try{var e=0;a.call(h,function(a){e++||(h=a,b())},function(a){e++||(h=a,c())})}catch(f){h=f,c()}else d()}function e(){var a;try{a=h&&h.then}catch(i){return h=i,g=2,e()}d(a,function(){g=1,e()},function(){g=2,e()},function(){try{1==g&&"function"==typeof b?h=b(h):2==g&&"function"==typeof c&&(h=c(h),g=1)}catch(e){return h=e,j()}h==f?(h=TypeError(),j()):d(a,function(){j(3)},j,function(){j(1==g&&3)})})}var f=this,g=0,h=0,i=[];f.promise=f,f.resolve=function(a){return g||(h=a,g=1,setTimeout(e)),this},f.reject=function(a){return g||(h=a,g=2,setTimeout(e)),this},f.then=function(b,c){var d=new a(b,c);return 3==g?d.resolve(h):4==g?d.reject(h):i.push(d),d};var j=function(a){g=a||4,i.map(function(a){3==g&&a.resolve(h)||a.reject(h)})}}"undefined"!=typeof module?module.exports=a:this.Promiz=a}();
```

Recently I came across [Promiscuous](https://github.com/RubenVerborgh/promiscuous), a tiny spec compliant library&nbsp;which was written about in this [blog post](http://ruben.verborgh.org/blog/2013/12/31/promiscuous-promises/). I commented that Promiz was nearly as small and provided more features, however as [Ruben](https://github.com/RubenVerborgh)&nbsp;pointed out, Promiz was not completely spec compliant. In fact, it had some major issues with regard to one particular use case where it failed completely. Here is an example of what would not have worked in the previous version of Promiz.js:

```js
var promise = Promiz.defer()
promise.resolve(42)

promise.then(function(fortyTwo) {
  console.assert(fortyTwo === 42)
  return 43
})

promise.then(function(fortyTwo) {

  // this fails, as it becomes 43
  console.assert(fortyTwo === 42)
})
```

Thanks to Ruben for pointing out my mistake, I then decided to make Promiz fully compliant. However I had a big issue, which was that the entire model of Promiz was based on stack based execution which would have been a nightmare to alter to be able to support the above feature. So instead **I re-wrote the whole thing**.

#### Basic Implementation
In the process or re-writing the library, I started out by creating a minimal spec compliant library which would pass all of the [promise spec tests](https://github.com/promises-aplus/promises-tests). This is what became Promiz Micro, and I'll go over some of the concepts behind it's implementation.

#### Promise State
If you notice the above code (and read the spec), it specifies that once a promise has been resolved or rejected, it's state must not change. This meant that I decided to chain objects together, similar to a Tree/Linked List, by tracking pointers to each promise in the chain. Because of this, we need variables to track state:

```js
var self = this

// .promise is required by the testing library, but not spec
self.promise = self

// once set, state is immutable
self.state = 'pending'
self.val = null

// success and error functions
self.fn = fn || null
self.er = er || null

// array of pointers to chained promises
self.next = [];
```

#### Resolve and Then
The implementation of the Resolve and Then functions is similar to the original implementation, except with Then it returns a new promise instead of itself:

```js
self.resolve = function (v) {
  if (self.state === 'pending') {
    self.val = v
    self.state = 'resolving'
    setImmediate(function () {
      self.fire()
    })
  }
  return this
}

self.then = function (fn, er) {
  var self = this
  var p = new promise(fn, er)

  if (self.state === 'resolved') {
    p.resolve(self.val)
  } else if (self.state === 'rejected') {
    p.reject(self.val)
  } else {
    self.next.push(p)
  }
  return p
}
```

#### 2.3.3.1 - [Let then be x.then](http://promises-aplus.github.io/promises-spec/#point-66)
One of the more frustrating parts of the spec is the requirement that the x.then function on a thenable (promise) is only accessed once. This means that when we check to see if an object has '.then', we have to save that value to a variable if we want to call it later. Not only that, when we try accessing that value, it may throw an exception ([2.3.3.3.4](http://promises-aplus.github.io/promises-spec/#point-78)).

```js
self.fire = function () {
  var self = this
  // check if it's a thenable
  var ref;
  try {
    ref = self.val && self.val.then
  } catch (e) {
    self.val = e
    self.state = 'rejecting'
    return self.fire()
  }
  ...
```

#### Resolve input promises, then apply functions, then resolve output promises
Part of the way I implemented the .resolve function meant that an input value (the current self.val) could potentially be a promise (this is part of the spec), so we have to resolve that promise before we do anything else. I created a helper function for this step, because we will want to re-use this code again for the last step of resolving the output value. We also have to protect the functions passed in because they are 'abused' in the testing code (not part of spec).

```js
// ref : reference to 'then' function
// cb, ec, cn : successCallback, failureCallback, notThennableCallback
self.thennable = function (ref, cb, ec, cn, val) {
  val = val || self.val
  if (typeof val === 'object' && typeof ref === 'function') {
    try {
      // cnt protects against abuse calls from spec checker
      var cnt = 0
      ref.call(val, function(v) {
        if (cnt++ !== 0) return
        cb(v)
      }, function (v) {
        if (cnt++ !== 0) return
        ec(v)
      })
    } catch (e) {
      ec(e)
    }
  } else {
    cn(val)
  }
}
```

#### Apply functions
This step is fairly straight forward. We need to apply the given functions to our current value, and watch out for errors.

```js
if (self.state === 'resolving' && typeof self.fn === 'function') {
  try {
    self.val = self.fn.call(undefined, self.val)
  } catch (e) {
    self.val = e
    return self.finish('rejected')
  }
}

if (self.state === 'rejecting' && typeof self.er === 'function') {
  try {
    self.val = self.er.call(undefined, self.val)
    self.state = 'resolving'
  } catch (e) {
    self.val = e
    return self.finish('rejected')
  }
}
```

#### 2.3.1 - [TypeError](http://promises-aplus.github.io/promises-spec/#point-57)
Part of the spec specifies that we should avoid direct circular loops, where we return our own promise as a return value from a function. If someone tries to do this, we need to throw a TypeError exception:

```js
if (self.val === self) {
  self.val = TypeError()
  return self.finish('rejected')
}
```

#### Finish
Finally, we finish up our call by finalizing our state and calling the next promise in the chain:

```js
self.finish = function (type) {
  self.state = type || 'rejected'
  self.next.map(function (p) {
    self.state == 'resolved' && p.resolve(self.val) || p.reject(self.val)
  })
}
```

#### Performance
This re-write, being spec compliant, no longer resolves synchronously. This means it takes a huge performance hit, but not more that other Promises/A+ compliant libraries already have to deal with. That being said, if you're after a fast (but heavy) Promises/A+ implementation, I recommend checking out [bluebird](https://github.com/petkaantonov/bluebird).
