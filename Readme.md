awesome config
==============

Here is my personal configuration of awesome.
Currently I use awesome v3.5 (Last Christmas)

with the following modules:

* shifty:
    - use [cdump's branch](https://github.com/cdump/awesome-shifty),
    - requires a patch to work with awesome v3.5

* vicious

WARNING: if you use awesome with lua5.2, you cannot use lognotify and wimpd.
They rely on luasocket, which is not avalaible for lua5.2. Personally I build
awesome with luajit ([awesome-luajit-git]() in AUR, if you are on archlinux)

* lognotify -> depends on inotify and luasocket (read the Readme of lognotify)

* in utils repository:
    - iwlist (wrapper around iwlist to display wifi-networks)
    - wimpd (widget for mpd, depends on luasocket)
    - cal (calendar popup)


Here is a screenshot:
![screen shot](https://github.com/downloads/Mic92/awesome-dotfiles/screenshot.png)
