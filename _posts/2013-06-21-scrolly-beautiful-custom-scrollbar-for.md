---
layout: post
title:  "Scrolly - A beautiful custom scrollbar for every page"
date:   2013-06-21
---

<style>::-webkit-scrollbar {     width: 12px;     height: 12px; }   ::-webkit-scrollbar-track-piece {     background: #aaa; }   ::-webkit-scrollbar-thumb {     background: #7a7a7a;     border-radius: 2px; }  ::-webkit-scrollbar-corner       {     background: #999; }  ::-webkit-scrollbar-thumb:window-inactive {     background: #888; } </style>

Scrolly is a chrome extension: [web store](https://chrome.google.com/webstore/detail/scrolly/emfaieckcngoebaoegbicknffolghnej) ([source](https://github.com/Zolmeister/Scrolly)) (live preview --&gt;)

It turns this ![](http://2.bp.blogspot.com/-kk8EAGLIpQU/UcPGLhoX1LI/AAAAAAAAAiM/OAQsNffhWKw/s1600/Selection_022.png)into this ![](http://3.bp.blogspot.com/-vZImjfgN1pA/UcPGNat8HmI/AAAAAAAAAiU/PGMyG6qTNpM/s1600/Selection_023.png)using css.

This is necessary because chrome does not use the scrollbars from your Linux theme:
> Because widget rendering is done in a separate, sandboxed process that doesn't have access to the X server or the filesystem, there's no current way to do GTK+ widget rendering. We instead pass WebKit a few colors and let it draw a default scrollbar. ([source](https://code.google.com/p/chromium/wiki/LinuxGtkThemeIntegration))</span></div><div style="text-align: left;">Here is the source:
```css
::-webkit-scrollbar {
    width: 12px;
    height: 12px;
}
::-webkit-scrollbar-track-piece {
    background: #aaa;
}
::-webkit-scrollbar-thumb {
    background: #7a7a7a;
    border-radius: 2px;
}
::-webkit-scrollbar-corner       {
    background: #999;
}
::-webkit-scrollbar-thumb:window-inactive {
    background: #888;
}
```

Feel free to fork it and change the css to be whatever you want. (pull requests welcome).

For more info on css scrollbars: [http://css-tricks.com/custom-scrollbars-in-webkit/](http://css-tricks.com/custom-scrollbars-in-webkit/)
