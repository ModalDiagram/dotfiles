#!/usr/bin/env bash
#
#
monitor=$(printf "eDP-1\nHDMI-A-1" | wofi -i --allow-images --height 210 --dmenu --cache-file /dev/null)
if [[ -z $monitor ]]; then exit; fi
mode=$(printf "disable\ndpms off" | wofi -i --allow-images --height 210 --dmenu --cache-file /dev/null)
if [[ -z $mode ]]; then exit; fi

if [[ $mode == "disable" ]]; then
  hyprctl keyword monitor $monitor,disable
else
  hyprctl dispatch dpms off $monitor
fi
