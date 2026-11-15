#!/bin/sh

userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap

# merge in defaults and keymaps

if [ -f $sysresources ]; then
    xrdb -merge $sysresources
fi

if [ -f $sysmodmap ]; then
    xmodmap $sysmodmap
fi

if [ -f "$userresources" ]; then
    xrdb -merge "$userresources"
fi

if [ -f "$usermodmap" ]; then
    xmodmap "$usermodmap"
fi

# start some nice programs

if [ -d /etc/X11/xinit/xinitrc.d ] ; then
 for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
  [ -x "$f" ] && . "$f"
 done
 unset f
fi

# Disable screen saver, screen blanking, and DPMS
/usr/bin/xset dpms 0 0 0
/usr/bin/xset -dpms
/usr/bin/xset s off
/usr/bin/xset s noblank

# Disable the X bell
/usr/bin/xset b off

# Pick the i3 setup based on which screens are connected
outputs=$(xrandr --query | awk '$2 == "connected" { print $1 }')
primary=$(echo "$outputs" | sed -n 1p)
secondary=$(echo "$outputs" | sed -n 2p)

if [ -n "$secondary" ]; then
    # The first connected output becomes primary, the second goes to its right.
    # Works for any connector names (DisplayPort-N, HDMI-N, eDP-N, ...).
    rotate=normal
    # The desktop's second DisplayPort monitor is mounted vertically
    [ "$secondary" = "DisplayPort-2" ] && rotate=left
    xrandr --output "$primary" --auto --primary \
           --output "$secondary" --auto --rotate "$rotate" --right-of "$primary"
    exec i3 -c "$HOME/.config/i3/config-dual"
else
    exec i3 -c "$HOME/.config/i3/config-single"
fi
