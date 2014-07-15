---
layout: post
title:  "Tanzania, Africa - In 1.75 Million Particles"
date:   2013-08-26
---

<iframe allowfullscreen="" frameborder="0" height="300" src="//tanzania.zolmeister.com" style="margin-left: -12px;" width="610"></iframe> Source:&nbsp;[github.com/Zolmeister/tanzania](https://github.com/Zolmeister/tanzania)&nbsp;(page: [tanzania.zolmeister.com/full](http://tanzania.zolmeister.com/full))
Note: Requires [WebGL](http://get.webgl.org/)

Alright, let me explain what you're looking at. If you fullscreen the app and have a 1080p monitor (1920x1080), then 1.75 million particles (1,753,920) will be generated and animated in real-time per image. Handling 1.75 million particles is no walk in the park, and without a decently fast GPU it may be quite slow. While it may not seem that complicated (as I thought at first), there is in fact a ridiculous amount of intense code involved. Lets begin!

So, I just came back from a vacation in Tanzania, Africa where I summited [Mt. Kilimanjaro](http://en.wikipedia.org/wiki/Mount_Kilimanjaro)&nbsp;(the highest free-standing mountain in the world - 5,895 meters), went on safari, and spent a week at the beach in Zanzibar. During my trip, I took ~2k photos, of which I selected ~150 (plus a few from friends I went with). I take pride in my photos, and I wanted to showcase them in a special way, so I decided to make a particle-based image viewer.

[![](http://2.bp.blogspot.com/-MOF5_MZSSlY/UhvcFJ2al8I/AAAAAAAAAno/_6lpiRz9MRs/s320/108.jpg)](http://2.bp.blogspot.com/-MOF5_MZSSlY/UhvcFJ2al8I/AAAAAAAAAno/_6lpiRz9MRs/s1600/108.jpg)

My first attempt was to try to use the HTML5 canvas object. This failed quickly and spectacularly, taking about a minute to render a single frame. This is because I was generating 1.75mil objects, each with an x, y, and color attribute, and then trying to update all of those objects x,y coordinated every frame.

[![](http://4.bp.blogspot.com/-57OvkZK0FyA/UhvcHwhLgtI/AAAAAAAAAnw/TBu4rfhPTeA/s320/96.jpg)](http://4.bp.blogspot.com/-57OvkZK0FyA/UhvcHwhLgtI/AAAAAAAAAnw/TBu4rfhPTeA/s1600/96.jpg)

For those that don't know, you get 16ms to do math every frame. This is the magic number which equates to a 60fps video stream, which also happens to align with most monitors refresh rates (60Hz), so even if you went over 60fps it wouldn't render any faster.

Let me put it this way. You can't even increment a number to 1.75mil in 16ms, and that's without doing any operations (on my cpu it took 1162ms). So the question is, how do you animate (change the x,y coordinates) 1.75mil particles? The GPU. GPUs, unlike CPUs, are really good at doing lots of small calculations in parallel. For example, your CPU probably has 4 cores, but your GPU may have 32, 64, or even 128 cores.

In order to take advantage of the GPUs ability to do massively parallel computing, we are going to need to use WebGL, and specifically the GLSL OpenGL shading language. I opted to use the great [Three.js](http://threejs.org/)&nbsp;WebGL framework. Three.js has quite poor documentation, but it has a great community and lots of examples to learn from. These examples were especially helpful (yes, to manually inspect the uncommented unintuitive source)

*   [Magic Dust](http://www.mrdoob.com/lab/javascript/webgl/particles/magicdust.html) ([Mr.doob](http://www.mrdoob.com/))
*   [nucleal](http://nucleal.com/) (I found this after I started working, and was extremely impressed)
*   [this jsfiddle](http://jsfiddle.net/yfSwK/27/)&nbsp;(extremely helpful)
*   [Particles_zz85](http://www.mrdoob.com/lab/javascript/webgl/particles/particles_zz85.html)&nbsp;(Mr.doob - GPU calculations)
*   [Mr.doob sandbox particle project](http://dl.dropboxusercontent.com/u/7508542/sandbox/particles/particles.html)&nbsp;(Mr.doob - CPU calculations)
*   These Particle System examples: [Dynamic](http://stemkoski.github.io/Three.js/ParticleSystem-Dynamic.html), [Attribute](http://stemkoski.github.io/Three.js/ParticleSystem-Attributes.html), [Shader](http://stemkoski.github.io/Three.js/ParticleSystem-Shader.html)
*   [Perlin Noise Fireball](http://www.clicktorelease.com/code/perlin/explosion.html) ([blog post](http://www.clicktorelease.com/blog/vertex-displacement-noise-3d-webgl-glsl-three-js))
*   [BufferGeometry Example](http://threejs.org/examples/webgl_buffergeometry.html)
*   [this other jsfiddle](http://jsfiddle.net/SSnKk/1/)
I also learned a lot from these amazing tutorials: [aerotwist.com/tutorials](http://aerotwist.com/tutorials)

Deviation: Here's how I took my 2k photos and picked a few.
[python script](https://gist.github.com/Zolmeister/6337546) to save select images while viewing them as a slide show
Image resize + crop bash script:
```bash
for file in *.jpg; do
  convert -size 1624x1080 $file -resize '1624x1080^' -crop '1624x1080+0+0' -quality 90 +profile '*' $file
done
```
Thumbnail bash script:
```bash
for file in *.jpg; do
  convert $file -resize 120x -quality 90 +profile '*' thumb/$file
done
```
File rename bash script:
```bash
for file in *.jpg; do
  mv "$file" "$file.tmp.jpg"
done
x=0
for file in *.jpg; do
  ((x++))
  mv "$file" "$x.jpg"
done
```
Alright, back to javascript. Let me explain a bit about how the GPU and WebGL work. You give WebGL a list of vertices (objects with x, y, z coordinates) that make up a 3D object mesh, and you give it a texture to be mapped to the vertices, this gives you a colorful 3D object. With a [ParticleSystem](http://threejs.org/docs/#Reference/Objects/ParticleSystem), you get a mesh (vertices) and you give it a texture that is applied per vertex. This means you cannot add or remove particles easily (though you can hide them from view), so you need create a mesh with as many vertices as you will need particles.

So, what happens is that these two things, the vertices and the texture, get passed into the Vertex Shader, and the Fragment Shader. First, everything goes to the Vertex Shader. The Vertex Shader may alter the position of vertices and move stuff around (this is important, as it will let us do animation on the GPU). Then the Fragment Shader takes over, and applies color to all the parts of the object, using the vertices as guides for how to color things (for shadows for example). Here is a [great tutorial](http://aerotwist.com/tutorials/an-introduction-to-shaders-part-1/).

Shaders are coded in a language called GLSL. Yeah, that already sounds scary. But it's not too bad once you spend a few hours banging your head against a wall. Here is what my (shortend) vertex shader looks like:
```
<script id='vertexshader' type='x-shader/x-vertex'>
  varying vec3 vColor;
  uniform float amplitude;
  uniform int transition;
  uniform int fullscreen;

  void main() {

    vColor = color;
    vec3 newPosition = position;
    newPosition = newPosition * (amplitude + 1.0) + amplitude * newPosition;
    vec4 mvPosition = modelViewMatrix * vec4( newPosition, 1.0 );
    gl_PointSize = 1.0;
    gl_Position = projectionMatrix * mvPosition;
  }
</script>
```
And here is what my fragment shader looks like:

```
<script id='fragmentshader' type='x-shader/x-fragment'>
  varying vec3 vColor;

  void main() {
    gl_FragColor = vec4(vColor, 1.0);
  }
</script>
```

Easy. GLSL has 3 main variables that get passed from javascript to the GPU.

*   varying - passed from the vertex shader to the fragment shader (used to pass attributes)
*   attribute - passed from JS to vertex shader only (per-vertex values)
*   uniform - global constant set by JS<div>Sometimes you can get away with doing a particle system by updating an 'attribute' variable for each particle, however this isn't feasible for us.

The way I will do animation (there are many ways), is to update a uniform (global constant) with a number from 0 to 1 depending on the frame I'm at. I will use the 'sine' function to do this, which will give me a smooth sequence from 0 to 1 and then back to 0 again.
```
// update the frame counter
frame += Math.PI * 0.02;

// update the amplitude based on the frame
uniforms.amplitude.value = Math.abs(Math.sin(frame))
```
Now, all I need to do to get cool animations is have each particle move with respect the the amplitude from its original location. Here is the second effect in the app (in the vertex shader):
```
newPosition = newPosition * (amplitude + 1.0) + amplitude * newPosition / 1.0;
newPosition = newPosition * (amplitude * abs(sin(distance(newPosition, vec3(0.0,0.0,0.0)) / 100.0))+ 1.0);
```
Now, as far as the fragment shader goes, you see I am updating the color from an attribute set by Three.js (`color`), which is the color per-pixel from the image to the vertex. This (I think) is quite inefficient (but fast enough for me), and the optimal way (I think) is to pass the image directly as a texture2D variable and let the fragment shader look at that to determine its color ([nucleal.com/](http://nucleal.com/)&nbsp;does that I think). However I couldn't &nbsp;figure out how to do this.

Here is the Three.js code for using a custom vertex and fragment shader:
```js
    uniforms = {
      // This dictates the point of the animation sequence
      amplitude: {
        type: 'f', // float
        value: 0
      },
      // Dictates the transition animation. Ranges from 0-9
      transition: {
        type: 'i', // int
        value: 0
      }
    }

    // Load custom shaders
    var vShader = $('#vertexshader')
    var fShader = $('#fragmentshader')

    material = new THREE.ShaderMaterial({
      uniforms: uniforms,
      vertexShader: vShader.text(),
      fragmentShader: fShader.text(),
      vertexColors: true,
      depthTest: false,
      transparent: true
    })

    particles = new THREE.ParticleSystem(geometry, material)
    scene.add(particles)
```
Now, we're missing the `geometry` part of the particle system, as well as a way to display the particles with a 1:1 pixel ratio to the screen. The latter is solved by some field-of-view voodoo code:
```js
camera = new THREE.PerspectiveCamera(90, width / height, 1, 100000)
// position camera for a 1:1 pixel unit ratio
var vFOV = camera.fov * (Math.PI / 180) // convert VERTICAL fov to radians
var targetZ = height / (2 * Math.tan(vFOV / 2))

// add 2 to fix rendering artifacts
camera.position.z = targetZ + 2
```
And the former is solved with a giant for-loop (Don't actually do this)
```
js
geometry = new THREE.Geometry()
var vertices = []
for(var i=0;i<1,750,000;i++){
  vertices.push(new THREE.Vertex(i, i*20 % (i/2), 0))
}
geometry.vertices = vertices
```
There are many things wrong with the code above (it won't even compile), but the most important part is to notice that it's pushing a NEW object every time it runs, and this is happening over 1million times. This loop is extremely slow, takes up hundreds of megabytes of memory, and breaks the garbage collector (but more on that later). Not to mention that you can't have a loading bar because it blocks the UI thread. Oh yeah, don't forget about colors! (This code is also ridiculously slow)
```js
geometry = new THREE.Geometry()
var colors = []
for(var i=0;i<1,750,000*3;i+3){
  var col = new THREE.Color()
  col.setRGB(imgData[i], imgData[i+1], imgData[i+2])
}
geometry.colors = colors
```
The first thing that came to mind that would fix both problems at once (sort of) is to use [Web Workers](https://developer.mozilla.org/en-US/docs/Web/Guide/Performance/Using_web_workers). However, when passing data to and from web workers it gets JSON.stringify 'd, which is horribly slow and takes forever (but there's another way - more later).

We can speed things up by using plain objects instead of Three.js objects (they seemed to work the same):
```js
var col = {r: 1, g: 2, b:3}
```
This is considerably faster, but still not fast enough. Well, it was fast enough for me for a bit, but then the app started randomly crashing. Turns out, I was using over 1GB of memory. No, I wasn't leaking memory, the problem was instead that the Garbage Collector could not run and crashed the app.

Here is a great video on [Memory management in the browser](http://www.youtube.com/watch?v=x9Jlu_h_Lyw) from GoogleIO, and I'll explain a little bit about GC. Javascript is a GC'd (Garbage Collected) language, which means you don't have to de-allocate memory you use. Instead what happens is you get 2 memory chunks. The first is short-term memory, and the second is long-term memory. Short term memory is collected often, and objects that survive long enough (aren't collected) move into long-term memory. In order to determine what memory can be collected safely, The garbage collector goes through every object and checks what objects can be reached from that object (an object graph if you will, as a tree with nodes). So when the GC runs on our app with 3million+ objects, it crashes.

Finally, after much headache, user `bai` on #three.js (freenode IRC) saved the day with the suggestion to use BufferGeometry in Three.js instead of just Geometry. BufferGeometry is exactly what I needed, as it exposes the raw typed javascript arrays used by WebGl, which means a huge performance increase and drastically reduced memory usage. I'm talking about going from 1GB of memory to 16MB.
```js
// BufferGeometry is MUCH more memory efficient
geometry = new THREE.BufferGeometry()
geometry.dynamic = true
var imgWidth = imgSize.width
var imgHeight = imgSize.height
var num = imgWidth * imgHeight * 3
geometry.attributes.position = {
  itemSize: 3,
  array: new Float32Array(<this comes from web workers>),
  numItems: num
}
geometry.attributes.color = {
  itemSize: 3,
  array: new Float32Array(num),
  numItems: num
}

//update colors
geometry.attributes.color.needsUpdate = true
```
Ok. At this point, I had a reasonably fast application, but it still had a few rough edges. Specifically, with the blocking UI thread when loading a new image (read the image pixel by pixel and update the geometry.attributes.color array - 1.75mil pixels). See, Javascript is single threaded, so when you have a long running loop, the whole webpage freezes up. This is where Web Workers come in (I told you they would be back).

Web workers spawn a new OS thread, which means no UI blocking. However we still have the issue of having to send data via objecting cloning. Turns out that there are special objects which are transferable (specifically ArrayBuffer objects), which pass by reference (vs copy) except that the catch is that they are removed from the original thread. eg. I pass an array to a worker, and I can no longer read it from my main thread, but I can in the worker thread. In order to understand how to take advantage of this, we need to understand [javascript typed arrays](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Typed_arrays).

Typed arrays in javascript consist of a read-only ArrayBuffer object, and a `viewer` which allows you to write data to the ArrayBuffer behind the scenes. For example, if I have an ArrayBuffer, I can create a viewer on top of it (cheaply) Uint8ClampedArray(ArrayBuffer), which lets me read and write data to the buffer. Now, lets look at how I pass the ArrayBuffers back and forth between the web worker thread and the main thread to offload heavy work.
(web worker code)
```
<script id='imageworker' type='text/js-worker'>
onmessage = function (e) {
  var pixels = new Uint8ClampedArray(e.data.pixels)
  var arr = new Float32Array(e.data.outputBuffer)
  var i = e.data.len

  while (--i >= 0) {
    arr[i*3] = pixels[i*4] / 255
    arr[i*3 + 1] = pixels[i*4+1] / 255
    arr[i*3 + 2] = pixels[i*4+2] / 255
  }

  postMessage(arr.buffer, [arr.buffer])
  return close()

};
</script>
```
(main thread code)
```js
function loadImage(num, buffer, cb) {
  var img = new Image()
  img.onload = function () {
    var c = document.createElement('canvas')
    imgWidth = c.width = img.width
    imgHeight = c.height = img.height

    var ctx = c.getContext('2d')
    ctx.drawImage(img, 0, 0, imgWidth, imgHeight)
    var pixels = ctx.getImageData(0, 0, c.width, c.height).data
    var blob = new Blob([$('#imageworker').text()], {
      type: "text/javascript"
    });
    var worker = new Worker(window.URL.createObjectURL(blob))
    console.time('imageLoad')

    worker.onmessage = function (e) {
      console.timeEnd('imageLoad')

      workerBuffer = geometry.attributes.color.array
      geometry.attributes.color.array = new Float32Array(e.data)
      cb && cb()
    };

    worker.postMessage({
      pixels: pixels.buffer,
      outputBuffer: workerBuffer.buffer,
      len: pixels.length
    }, [pixels.buffer, workerBuffer.buffer])

  }
  img.src = 'imgs/' + num + '.jpg'
}
```
(Bonus: console.time(), console.timeEnd() - useful timing shortcuts)

And that's it! It wasn't easy, but I definitely learned a lot.
