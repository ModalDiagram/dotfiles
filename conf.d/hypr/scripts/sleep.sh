#!/bin/sh

exec swayidle -w \
  timeout 300 'notify-send -t 10000 --urgency=critical "Turning off in 10 seconds"' \
  timeout 310 'hyprctl dispatch dpms off eDP-1' resume 'hyprctl dispatch dpms on eDP-1;' \
  timeout 309 '$HOME/.local/share/my_lock/my_lock.sh' \
  before-sleep '$HOME/.local/share/my_lock/my_lock.sh'

