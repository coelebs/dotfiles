#!/bin/sh

#
# ~/.xinitrc
#
# Executed by startx (run your window manager from here)
#
xsetroot -cursor_name left_ptr &
sh ~/.fehbg &
conky | dzen2 -fn '-*-terminus-*-*-*-*-12-*-*-*-*-*-*-*' -bg black -fg grey -h 14 -w 1380 -x 300 -ta r &
numlockx &
unclutter -idle 2 -jitter 5 &
setxkbmap us &
sleep 3 &
xmodmap ~/.Xmodmap &
urxvtd &

exec xmonad
