#!/bin/sh

if [[ "$1" == "open" ]]; then
  hyprctl keyword monitor "eDP-1,2880x1800@60,auto,2"
else
  hyprctl keyword monitor "eDP-1,disable"
fi

# if [[ "$(hyprctl monitors)" =~ "HDMI-A-1" ]]; then 
#   if [[ "$1" == "open" ]]; then
#     hyprctl keyword monitor "eDP-1,2880x1800@60,auto,2"
#   else
#     hyprctl keyword monitor "eDP-1,disable"
#   fi
# else
#   if [[ "$1" == "open" && "$(hyprctl monitors)" =~ "eDP-1" ]]; then
#     ~/.local/share/my_lock/my_lock.sh
#   else
#     hyprctl keyword monitor "eDP-1,2880x1800@60,auto,2"
#   fi
# fi
