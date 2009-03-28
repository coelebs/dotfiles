#!/bin/sh

#
# ~/.xinitrc
#
# Executed by startx (run your window manager from here)
#
xsetroot -cursor_name left_ptr &
xmodmap ~/.Xmodmap &
sh ~/.fehbg &
#xbindkeys &
conky | dzen2 -fn '-*-terminus-*-*-*-*-12-*-*-*-*-*-*-*' -bg black -fg grey -h 14 -w 1380 -x 300 -ta r &
numlockx &
unclutter 2 &
setxkbmap us &

exec xmonad
