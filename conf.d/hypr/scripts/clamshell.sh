#!/bin/sh

# if [[ "$1" == "open" ]]; then
#   hyprctl keyword monitor "eDP-1,2880x1800@60,auto,2"
# else
#   hyprctl keyword monitor "eDP-1,disable"
# fi

if [[ "$1" == "open" && ! "$(hyprctl monitors)" =~ "eDP-1" ]]; then
  hyprctl keyword monitor "eDP-1,2880x1800@60,0x0,2"
  return
fi
if [[ "$(hyprctl monitors)" =~ "HDMI-A-1" ]]; then
  hyprctl keyword monitor "eDP-1,disable"
fi
