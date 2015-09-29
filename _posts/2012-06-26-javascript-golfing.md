---
layout: post
title:  "Javascript Golfing"
date:   2012-06-26
---

![](http://www.clker.com/cliparts/4/3/d/0/1207314048614869515golfing%20black.svg.med.png)

#### What is Javascript Golfing?
Well, Javascript golfing is the&nbsp;process&nbsp;of writing the smallest amount of javascript code to do something awesome. It tests your ability to reduce, reuse, and recycle for the purpose of achieving the tiniest footprint possible. Also, it's fun!
Note: All of these games and more can be found here: [Games.Zolmeister.com](https://games.zolmeister.com/)

#### First attempt, [Snake](https://games.zolmeister.com/snake/tinySnake/):
My first attempt at golfing was inspired by [MXSnake](http://www.strille.net/works/snake_game_1Kb.php) (back when I didn't even&nbsp;know&nbsp;it was called golfing). Here is my version: [tinySnake](https://games.zolmeister.com/snake/tinySnake/) (686 bytes). Kind of large, not too pretty and nothing really special, except my key events which I think are quite unique.

```js
onkeydown = function (a) {
  q = a.which - 38;
  q % 2 ? n = 0 : n = q - 1;
  q % 2 ? e = q : e = 0
}
```

I realized that the key presses should be directly tied to the movement variables of the snake, so I used the keyCode itself to set the movement (I think it could be done even more elegantly, but it's a start).

#### Second attempt, [Pong](https://games.zolmeister.com/pong.html):
My second attempt at golfing was inspired by an [article](http://alokmenghrajani.github.com/tron/) on hacker-news I read about, where someone made tron in 219 bytes(!). Instead of trying to best them though, I made [Pong (451 bytes)](https://games.zolmeister.com/pong.html) instead. (Screen is blank until you hit a key, W and A for p1 movement and UP and DOWN for p2 movement). Sadly I don't have the original non-compressed code, but my technique for compression mimicked the tron game.

#### Third Attempt, [Two Towers](https://games.zolmeister.com/twotowers(miniv2).html):
[![](http://1.bp.blogspot.com/-bUXMZCyCPes/T-lOu80EaPI/AAAAAAAAATQ/2k9X1CX1XeY/s200/twotowers.png)](https://games.zolmeister.com/twotowers(miniv2).html)

After feeling good about my pong implementation, I decided I wanted to make something new and original. I settled on a game where the player spawns objects to attack an enemy base. Another constraint I wanted to have was to keep it below 1KB (it's [1008 bytes&nbsp;currently](https://games.zolmeister.com/twotowers(miniv2).html)), so that it could be compared to the applications at&nbsp;[http://js1k.com](http://js1k.com/)&nbsp;(definitely check this out, there are some truly amazing apps people created). This time I did not lose the original non-compressed source:

```js
 C = c.getContext('2d')
 money = time = level = 1 //multiple assignments in one statement reduces the use of semicolons
 upgrade = .99
 R = Math.random; //assign common functions to variables
 enemies = [{
   size: 50,
   x: 650,
   speed: -1 / 1e99
 }] //use e for large values (1e3=1000) - saved 1 byte
 friendlies = [{
   size: 50,
   x: 70,
   speed: 0
 }] //use unique variable names for easy hand-minification
 C.fillRect(0, 0, c.width, c.height);
 part1 = "<button onclick='";
 part2 = "</button>"
 doc = document
 for (i = 3; i < 10; i++)
 doc.write(part1 + "buy(" + i + ")'>$" + i * 10 + part2);
 //using ~~ instead of parseInt helps a lot
 doc.write(" Upgrade: " + part1 + "upgradeValue=~~(200/upgrade-200)*10+100;money-upgradeValue<0?i:(upgrade-=.05,money-=upgradeValue);this.innerHTML=upgradeValue'>" + upgrade * 100 + part2);
 //keep functions to a minimum (the word function is expensive)
 //the function below gets removed and the whole thing inserted in an onclick event
 function buy(n) {
   n = n / upgrade * 10
   money -= n * upgrade;
   money < 0 ? money += n : friendlies.push({
     size: ~~ (Math.pow(n, 2) / 250) + 5,
     x: 100,
     speed: 60 / n
   });
 }

 function animation() {
   if (R() < .03) //AI code (random is your friend)
   enemies.push({
     size: ~~ (R() * level) + 7,
     x: 650,
     speed: -(level - R())
   })
   C.clearRect(0, 0, 700, 300);
   C.fillText("$" + ~~money, 9, 9)
   //concat both friendlies and enemies for updating the objects (drawing and moving)
   g = [].concat(enemies, friendlies)
   for (i in enemies) {
     for (j in friendlies) {
       //during minification, && and || can usually be replaced by & and | respectively
       if (friendlies[j].x + friendlies[j].size >= enemies[i].x - enemies[i].size && enemies[i].size > 0 && friendlies[j].size > 0) {
         --friendlies[j].size < 0 ? friendlies[j].size++ : i;
         enemies[i].size == 1 ? money += enemies[i].size : i;
         --enemies[i].size < 0 ? enemies[i].size++ : i;
         enemies[i].x -= enemies[i].speed;
         friendlies[j].x -= friendlies[j].speed;
       }
     }
   }
   for (i in g) {
     g[i].x += g[i].speed
     //I used negative speed values to differenciate between enemies and friendlies
     C.fillStyle = g[i].speed < 0 ? '#F10' : '#10F';
     C.save()
     time += .01
     C.translate(g[i].x, 150 - g[i].size)
     C.rotate(time * (g[i].speed < 0 ? -1 : 1))
     C.font = g[i].size + 'pt txt';
     //thanks http://js1k.com/2010-first/demo/750 for the inspiration to use unicode
     C.fillText(String.fromCharCode(1161), g[i].size / 2, g[i].size / 2)
     C.restore()
   }
   //inline if statements are better if doing one action
   //friendlies[0].size==0?history.go():i;
   //function are special
   friendlies[0].size == 0 && history.go();
   //regular ifs are more eficient for more than 1 call
   if (enemies[0].size == 0) friendlies = [friendlies[0]], enemies[0].size = 50, level++, money += 500;
   money += .25;
   time += .1
 }
 //put the function inside of quotes in the interval call later to save space
 setInterval(animation, 50)
```

#### Finally, here are some tips for golfing:

Look at other peoples code. They come up with interesting tricks like this one (to remap the canvas calls to have shorter names):
```js
for($ in C=c.getContext('2d'))C[$[0]+$[6]]=C[$];
```
-Source: [Bouncing Beholder](http://marijnhaverbeke.nl/js1k/) (This game is crazy-good, worth reading through the source)
Check out this [tutorial](http://codegolf.stackexchange.com/questions/2682/tips-for-golfing-in-javascript) on stackexchange.
Use a tool like [jscrush](http://www.iteral.com/jscrush/)&nbsp;after you hand-minify your code (and check that [closure compiler](http://closure-compiler.appspot.com/home) won't help).
Good Luck!
