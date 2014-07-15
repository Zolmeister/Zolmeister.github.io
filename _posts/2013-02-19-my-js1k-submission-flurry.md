---
layout: post
title:  "My js1k submission: Flurry"
date:   2013-02-19
---

App:&nbsp;[Flurry](http://js1k.com/2013-spring/demo/1345)

In my [second blog post](http://www.zolmeister.com/2012/06/javascript-golfing.html)&nbsp;I wrote about javascript golfing, and how it is a great way to entertain yourself and learn some cool tricks along the way. With [js1k](http://js1k.com/2013-spring/)&nbsp;underway (you can submit till Match 31st), I have decided to write about my submission, Flurry. Now originally it was going to use both the [Full Screen API](https://developer.mozilla.org/en-US/docs/DOM/Using_fullscreen_mode), as well as the [Pointer Lock API](https://developer.mozilla.org/en-US/docs/API/Pointer_Lock_API)&nbsp;(Mozilla misspelled their call with a capital S in screen), however after submitting it turned out that webkit blocks (be default) the fullscreen/pointerlock from within a frame (which is how js1k hosts submissions). I was&nbsp;disappointed&nbsp;but moved on to a variant that didn't use those calls.

The final code came in at 1023 bytes, here is the original&nbsp;uncompressed&nbsp;source (4.8 kB):
```js
     /*
 * By: Zolmeister
 * http://zolmeister.com
 */
mouseX = mouseY = 0
flowers = []
// Z
letter = [
  [.3579, .1628],
  [.6421, .1599],
  [.3512, .7326],
  [.6488, .7297]
]
onmousemove = function (e) {
  mouseX = e.pageX
  mouseY = e.pageY
}
cHi = c.height = innerHeight - 21
setInterval(function () {
  if (mouseX) {
    cWid = c.width = innerWidth - 21
    //with with is with
    with(a) {
      with(Math) {
        rand = random
        //Align text so that it rotates cleanly
        textBaseline = 'middle'
        textAlign = 'center'
        shadowColor = '#222'
        if (rand() >.6 & flowers.length < 2) {
          //spawn flower
          flow = rand() * 27 + 10025
          dir = rand() * PI * 2
          flower = {
            x: mouseX,
            y: mouseY,
            dir: dir,
            xSpeed: cos(dir),
            ySpeed: sin(dir),
            flower: String.fromCharCode(flow), //unicode flowers
            rot: 0,
            poptime: 20,
            size: 90,
            color: '#' + ['FA7A79', 'A266AC', 'E38F3D', '81A63F', '619CD8'][~~(rand() * 5)]
          }
          flowers.push(flower)
        }
        for (i in flowers) {
          with(flowers[i]) {
            dir %= 2 * PI
            //wall collision in radians
            if (x < 70 | x > cWid - 70) {
              xSpeed *= -1
              if (x < 70) x = 70
              if (x > cWid - 70) x = cWid - 70
            }
            if (y < 70 | y > cHi - 70) {
              ySpeed *= -1
              if (y < 70) y = 70
              if (y > cHi - 70) y = cHi - 70
            }
            x += xSpeed * 16
            y += ySpeed * 16
            last = letter[0]
            for (j = 1; j < 4; j++) {
              x1 = cWid * last[0]
              y1 = cHi * last[1]
              x2 = cWid * letter[j][0]
              y2 = cHi * letter[j][1]
              m = (y1 - y2) / (x1 - x2)
              yy = m * (x - x1) + y1
              if (x < max(x1, x2) & x > min(x1, x2)) {
                if (abs(y - yy) < 10) {
                  x -= xSpeed * 15.9
                  y -= ySpeed * 15.9
                  j = 4
                }
              }
              last = letter[j]
            }
            rot += PI / 9
            poptime -= 1
            if (flowers.length < 150 & poptime < 0 & & size & & abs(x - mouseX) < size / 2 & abs(y - mouseY) < size / 2) {
              size *= .9
              poptime = 30
              dir = rand() * PI * 2
              xSpeed = cos(dir)
              ySpeed = sin(dir)
              for (i = 0; i < 10; i++) {
                dd = rand() * PI * 2
                xx = mouseX + cos(dd) * 45
                yy = mouseY + sin(dd) * 45
                flowers.push({
                  x: xx,
                  y: yy,
                  xSpeed: cos(dd),
                  ySpeed: sin(dd),
                  dir: dd,
                  flower: String.fromCharCode(rand() * 27 + 10025), //unicode flowers
                  rot: 0,
                  poptime: 20,
                  size: size,
                  color: '#' + ['FA7A79', 'A266AC', 'E38F3D', '81A63F', '619CD8'][~~(rand() * 5)]
                })
              }
            }
            //draw rotated flower
            font = size + 'px sans'
            shadowBlur = 3;
            fillStyle = color
            save()
            translate(x, y)
            rotate(rot)
            fillText(flower, 0, 0)
            restore()
          }
        }
      }
    }
  }
}, 33)
```
I would like to point out some of the most useful things I used to save bytes in this, namely using the javascript 'with' call, along with ~~, &, |. &nbsp;~~ is used to convert a float to an integer, and the binary operators were used to replace the traditional 'or' (||) and 'and' (&&). The binary operators don't work in all cases however (from my experience it works with boolean expressions but not 'truthy' values (ie, strings or numbers !=0). The real gem in the code however is the rampant use of the 'with' call. I make a &nbsp;lot of calls to the canvas context (as well as math operations sin, cos, abs) and also within loops to object properties. I was surprised to find out that you can assign values such as 'shadowBlur=3' within a 'with' block and have it work out nicely.

Other than that, the only thing worth noting is that if you want to get spinning text (in my case unicode) its easiest (and the only way I got to work) to set the textBaseline='middle' and textAlign='center' on the canvas context. This positions the text (nearly) perfectly so that it rotates flawlessly. Without that, you get weird circulating objects (which is what happens to objects that are spun offset from their center).

Finally, after hand minifying my code by renaming variables and moving a few bits of code around accordingly and also shortening 'if' blocks with ternary operators, I passed the code first through the [google closure compiler service](http://closure-compiler.appspot.com/home)&nbsp;and then through [JSCrush](http://www.iteral.com/jscrush/). This gave me a tidy line of 1023 bytes and concluded my js1k submission.

```js
_='X=Y=0;D=[];G=[[ 358`16 2`16 [ 351`73 9`73]];onmousemove= b X X;Y Y};K=c.hQZHQ-21;setIn rval(  if(X J=c.wid!ZWid!-21; a) Ma!) i   M=random, xtBasel e="mikle  xtAlign="cen r  Color="#222  6< &2 &$ ,     Xq:Y,N:N,A: $ B:z$) 90  D) D[i] N%=2*PI; >x|x>J A x (x=  x>J x=J- )  >y|y>K B y (y=  y>K y=K- ) x+?6*A;y+?6*B;P=G[0]; j?;4>j;j++)T=J*P[0 V=K*P[1 U=J* [0 W=K* [1 R=(V-W)/(T-U)*(x-T)+V,x<max^&x>m ^ 10> y-R) (x Aq B,j=4 P= ;O+=PI/9;F-?;if(150 0>F H  x-X_& y-Y_ H*= 9;F=30;N ;A= $ B=z$  i=0;10>i;i++)k ,L=X+45*  R=Y+45*z      Lq:R,A:  B:z N:k H }font=H+"px sans"; Blur=3;fillStyle=I;save( transla (xq rota (O fillText(E,0,0 restore()}}},33) ,I:"#"+["FA7A79@A266AC@E38F3D@81A63F@619CD8"][~~(5* )]}) ,E:Str g.fromCharCode(27* +10025 O:0,F:20,H: =2* *PI -  ( (k  0\. in >D.leng!&     D.push({x: 70 wi!( function( ); ],@, ), && M() cos for( G[j] abs( =b.page *=-1, > -?5.9* te 3 [ 64 shadow ){!th$(N?=1@ "QeightZ= ner^(T,U)_)<H/2`, kddq,yzs ';for(Y=0;$='zqk`_^ZQ@?$!                                 '[Y++];)with(_.split($))_=join(pop());eval(_)
```
