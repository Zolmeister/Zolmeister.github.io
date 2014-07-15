---
layout: post
title:  "Retin.us - A new way to consume RSS"
date:   2013-06-30
---

[http://Retin.us](http://retin.us/) &nbsp;([chrome extension](https://chrome.google.com/webstore/detail/retinus-checker/bkoakabmfkmnpjmohnmmjgogplofobdg)) ([source](https://github.com/Zolmeister/Retinus))

Retin.us is not a Google Reader clone. Retin.us doesn't star or share articles. Retin.us doesn't `like` things, nor does it show you pretty pictures in a collage.

Retin.us does one thing, and it does it well. RSS (Rich Site **Summary**). Here is what it looks like:
[![](http://4.bp.blogspot.com/-SFldMr5wkfw/UdDcxyhaZqI/AAAAAAAAAi8/c7cktyj6uuI/s640/Selection_024.png)](http://retin.us/)

That's it. That's all there is. In fact, you can even minimize the sidebar:
[![](http://3.bp.blogspot.com/-zMSAA3MvARo/UdDf-9vbVHI/AAAAAAAAAj8/9fWoEjyY0TM/s1600/Selection_025.png)](http://3.bp.blogspot.com/-zMSAA3MvARo/UdDf-9vbVHI/AAAAAAAAAj8/9fWoEjyY0TM/s597/Selection_025.png)

Retin.us is based off of my Google Reader usage pattern:

*   J (key) - next&nbsp;
*   K (key) - previous
*   Ctrl + Enter - open selected article in new tab without losing focusing

When I open up my reader, I go through every unread item and open interesting articles in a new tab without losing focus. This is a bit different than most people who expect to read the article within their reader. There are many problems I found with this paradigm:

*   Long articles are unwieldy to read inline.
*   Collage based layouts are silly (Flipboard)
*   Some sites do not provide full articles in their RSS
*   Hacker News / Reddit subscriptions don't include any article data

As with my Google Reader app [ZFeed](http://www.zolmeister.com/2013/03/zfeed.html), instead of relying on unreliable RSS feed data, I fetch a summary of each article using the [embed.ly](http://embed.ly/) api. This way I can read the title and summary of an article before I make the decision to commit time to reading the whole thing.

There is still a lot more to come for Retin.us, but I have (as of last week) officially made it my RSS reader replacement. Expect another article soon about how it was built using [Sails.js](http://sailsjs.org/) and [Backbone](http://backbonejs.org/). In the meantime, feel free to contribute on [GitHub](https://github.com/Zolmeister/Retinus) (GPL license).</div>
