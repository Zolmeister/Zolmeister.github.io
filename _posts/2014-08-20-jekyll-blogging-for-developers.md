---
layout: post
title:  "Jekyll - Blogging for Developers"
date:   2014-08-20
---

[![](/assets/images/blog-header.png)](/2014/08/jekyll-blogging-for-developers.html)

You may have noticed that this blog moved from [Blogger](http://zolmeister.blogspot.com/)
to a [Ghost themed](https://github.com/rosario/kasper) [Jekyll website](http://jekyllrb.com/)
hosted on [GitHub pages](https://pages.github.com/). It's been a long time coming,
and I couldn't be more happy with how things turned out.

### Jekyll on GitHub
[Jekyll](https://pages.github.com/) is a static site generator, which allows you
to create websites with markdown easily.
[All of my posts](https://github.com/Zolmeister/Zolmeister.github.io/tree/src/_posts)
can thus be written in markdown, with code highlighting and version control thanks to GitHub hosting.

To get started, all you need is to find an open source theme that you like
(e.g. [Kapsper](https://github.com/rosario/kasper)), clone it, and run `jekyll serve` (after installing Jekyll).
Because the posts are written in markdown, you can use your
[favorite markdown editor](http://dillinger.io/) to write your posts in, or just your editors [markdown preview](https://atom.io/packages/markdown-preview)

### Free Hosting
Hosting on GitHub is completely free (for your first site), and works seamlessly with Jekyll, until you need a plugin.
This was the case with [Jekyll RSS](https://github.com/agelber/jekyll-rss)
which is a plugin that generates an RSS feed from my blog posts.  

In order to get plugins to work, you need to compile in a separate git branch,
and then deploy to `master`. Here is my source branch:
[Zolmeister.github.io/tree/src](https://github.com/Zolmeister/Zolmeister.github.io/tree/src)

Here is the `publish.sh` script I wrote to make publishing quicker (DO NOT EDIT ON THE MASTER BRANCH):

```bash
#!/bin/bash

jekyll build
mv _site/ /tmp/
git checkout master
rm -r *
cp -r /tmp/_site/* .
rm -r /tmp/_site/
git add . -A
git commit -am'publish'
```

### Other platforms
I considered many other platforms before stumbling across Jekyll.
Namely [Ghost](https://ghost.org/), [Medium](https://medium.com/),
and [Svbtle](https://svbtle.com/).
Both Medium and Svbtle control the display of posts, which is a big downside,
but they are extremely simple to use just for writing.

Ghost was most interesting,
and my inspiration for a [Blogging for Developers](http://localhost:4000/2014/02/dematerializer-blogging-for-developers.html)
hackathon project. However, it's development has been slow in coming partially due
to a [rewrite in Ember.js](https://github.com/TryGhost/Ghost/issues?q=milestone%3A%220.4+Ember.js%22)
which took about 4 months. I simply couldn't wait this long, and without free
time to contribute to the project I had to abandon the idea of using it.

### Closing thoughts
Blogging is a passion of mine. It brings me joy to catalog my activity to help me reflect
on the projects I have worked on. I believe it makes me a stronger developer and
has been a motivating force behind a lot of the open source work that I do.
I would recommend technical blogging to every developer, no matter what projects you work on.
