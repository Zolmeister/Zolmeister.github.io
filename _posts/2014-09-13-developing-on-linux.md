---
layout: post
title:  "Developing on Linux"
date:   2014-09-13
---
[![desktop](https://zolmeister.com/assets/images/desktop.png)](https://github.com/Zolmeister/dotfiles)

### [dotfiles](https://github.com/Zolmeister/dotfiles)

## i3 - Tiling Window Manager

A tiling window manager is a type of window manager that arranges your windows as tiles,
usually in such a way that makes managing them more efficient via keyboard shortcuts.
[i3](http://i3wm.org/) is my window manager of choice, after having used [xmonad](http://xmonad.org/)
for a long time, i3 provides more flexibility and ease of configuration.

Here is a [great sceencast](https://www.youtube.com/watch?v=Wx0eNaGzAZU) which will help you understand the power of tiling window managers.
i3 does a great job of managing multiple workspaces, even across multiple monitors.
While developing I actively use 7 distinct workspaces across two monitors (soon probably three)
and having an efficient way of transitioning (`alt-#`) is critical to maintaining my workflow speed.

Here is a bit of config that I added to i3 (see dotfiles for the full version)

```
# Zolmeister
# disabled status bar (see above)
# screen lock with ctrl + sup + l
bindsym Control+mod4+l exec i3lock -c 000000 -i ~/Pictures/Z/Z-bg.png
# set border to 1
new_window 1pixel
# hide border if 1 window
hide_edge_borders both
# Resize Containers, Vim-style                            ($mod+Control+[hjkl])
bindsym $mod+Control+j resize grow height 5 px or 5 ppt
bindsym $mod+Control+k resize shrink height 5 px or 5 ppt
bindsym $mod+Control+l resize grow width 5 px or 5 ppt
bindsym $mod+Control+h resize shrink width 5 px or 5 ppt

# custom colors
# class                 border  backgr. text    indicator
client.focused                #1793D0    #1793D0    #FFFFFF
client.focused_inactive    #333333    #333333    #999999
client.unfocused            #333333    #333333    #999999
client.urgent                #FF0000    #8C5665    #FF0000

# background image
exec --no-startup-id nitrogen --restore

# fix media keys and gtk theme issues
exec gnome-settings-daemon &

# fix deb file installation
exec /usr/lib/policykit-1-gnome/polkit-gnome-authentication-agent-1 &
```

## ZSH + Powerline Shell
Most shells today run [Bash](http://en.wikipedia.org/wiki/Bash_(Unix_shell)
however [ZSH](https://github.com/robbyrussell/oh-my-zsh) is an alternative which
has great autocompletion and [other nifty feature](http://www.slideshare.net/jaguardesignstudio/why-zsh-is-cooler-than-your-shell-16194692)
For my `.zshrc` file, check my dotfiles.

In addition, the ZSH framework [oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh)
provides some amazing features and
[shortcuts](https://github.com/robbyrussell/oh-my-zsh/wiki/Cheatsheet),
definitely work checking out.

[Powerline shell](https://github.com/milkbikis/powerline-shell) is a beautiful
shell extension which takes care of drawing your prompt. I have customized it
based on my ZSH theme to include additional git hints (like ±).

[![shell](https://zolmeister.com/assets/images/shell.png)](https://github.com/robbyrussell/oh-my-zsh)

## Atom.io

[Atom.io](https://atom.io/) is without a doubt the best editor I have ever used.
I have used [Aptana](http://www.aptana.com/) (good, but bloated),
[Sublime Text](http://www.sublimetext.com/) (excellent, but not open source),
and [Brackets](http://brackets.io/?lang=en) (ok, missing quite a few features) extensively.
None of them compare to Atom (I refuse to use an editor that is not open-source, as
my editor is a core part of my development workflow and I must have full control over it).

Some day I may switch to VIM/Emacs, but have been quite happy with my working speed in Atom.

## Hardware

After [joining Clay.io](http://zolmeister.com/2014/07/cto-cofounder-clay-io.html)
I have finally gotten around to building another desktop. The only spec requirements I had
were a Linux friendly GPU (Nvidia), 32GB of RAM, and 4k monitor support.

Here is the build ([newegg wishlist](http://secure.newegg.com/WishList/PublicWishDetail.aspx?WishListNumber=25084652), missing PSU + case):

  - [28" 4K monitor](http://www.newegg.com/Product/Product.aspx?Item=0JC-0007-00009)
  - [32GB DDR3 RAM](http://www.newegg.com/Product/Product.aspx?Item=N82E16820148800)
  - [i7 4790K](http://www.newegg.com/Product/Product.aspx?Item=N82E16819117369)
  - [256GB SSD](http://www.newegg.com/Product/Product.aspx?Item=N82E16820148820)
  - [GeForce GTX 760](http://www.newegg.com/Product/Product.aspx?Item=N82E16814127748)
  - [1000W PSU](http://www.amazon.com/gp/product/B003J89V0A/ref=oh_aui_detailpage_o03_s00?ie=UTF8&psc=1)
  - [2TB HD](http://www.newegg.com/Product/Product.aspx?Item=N82E16822148834)
  - [21.5" monitor](http://www.newegg.com/Product/Product.aspx?Item=N82E16824009316)
  - [NZXT ATX Mid Tower](http://www.newegg.com/Product/Product.aspx?Item=N82E16811146061)
  - [ASRock Motherboard](http://www.newegg.com/Product/Product.aspx?Item=N82E16813157372)
