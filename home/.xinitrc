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

# Monitors that are mounted vertically, one EDID model name per line (see the
# "Display Product Name" in `edid-decode`, or `xrandr --prop`). Identifying the
# monitor itself rather than its connector keeps this working when cables are
# moved to other ports or the monitor is plugged into another machine.
vertical_monitors="BenQ PD2705U"

# Print the connected outputs whose monitor has the EDID model name $1
outputs_with_monitor() {
    name_hex=$(printf '%s' "$1" | od -An -tx1 | tr -d ' \n')
    # 000000fc00 is the header of the EDID "display product name" descriptor
    xrandr --prop | awk -v needle="000000fc00$name_hex" '
        function flush() { if (out != "" && index(edid, needle)) print out }
        /^[^ \t]/ { flush(); out = ($2 == "connected") ? $1 : ""; edid = ""; in_edid = 0; next }
        /^\tEDID:/ { in_edid = 1; next }
        in_edid && /^\t\t[0-9a-f]+$/ { edid = edid $1; next }
        { in_edid = 0 }
        END { flush() }'
}

# Pick the i3 setup based on which screens are connected
connected=$(xrandr --query | awk '$2 == "connected" { print $1 }')
vertical=$(echo "$vertical_monitors" | while IFS= read -r monitor; do
    [ -n "$monitor" ] && outputs_with_monitor "$monitor"
done | sed -n 1p)

if [ "$(echo "$connected" | grep -c .)" -ge 2 ]; then
    # A vertical monitor is always the secondary screen. Otherwise the first
    # connected output becomes primary and the next one secondary, whatever the
    # connectors are called (DisplayPort-N, HDMI-N, eDP-N, ...).
    if [ -n "$vertical" ]; then
        secondary=$vertical
        rotate=left
    else
        secondary=$(echo "$connected" | sed -n 2p)
        rotate=normal
    fi
    primary=$(echo "$connected" | grep -vxF "$secondary" | sed -n 1p)

    # Lay out the screens before i3 starts, so that i3 sees the final layout
    # and config-dual can refer to them as "primary" and "nonprimary".
    xrandr --output "$primary" --auto --primary \
           --output "$secondary" --auto --rotate "$rotate" --right-of "$primary"
    exec i3 -c "$HOME/.config/i3/config-dual"
else
    exec i3 -c "$HOME/.config/i3/config-single"
fi
