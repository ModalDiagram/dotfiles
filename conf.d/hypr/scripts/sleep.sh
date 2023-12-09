#!/bin/sh

exec swayidle -w \
  timeout 480 'notify-send -t 120000 --urgency=critical "Spegnimento in 120 secondi"' \
  timeout 600 '$HOME/scripts/my_lock/my_lock.sh' \
  timeout 630 'swaymsg "output * dpms off"' resume 'swaymsg "output * dpms on"' \
  before-sleep '$HOME/.local/share/my_lock/my_lock.sh'

