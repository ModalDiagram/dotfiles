#!/usr/bin/env bash


if [[ $1 == *menu* ]]; then
  monitor=$(printf "eDP-1\nHDMI-A-1" | wofi -i --allow-images --height 210 --dmenu --cache-file /dev/null)
  if [[ -z $monitor ]]; then exit; fi
  mode=$(printf "disable\ndpms off" | wofi -i --allow-images --height 210 --dmenu --cache-file /dev/null)
  if [[ -z $mode ]]; then exit; fi

  if [[ $mode == "disable" ]]; then
    hyprctl keyword monitor $monitor,disable
  else
    hyprctl dispatch dpms off $monitor
  fi
fi

focused_monitor=$(hyprctl -j monitors |  jq '.[] | select(.focused == true)')
name=$(echo $focused_monitor | jq .name)
name=${name%\"*}
name=${name#*\"}
if [[ $1 == *dpms* ]]; then
  dpms_status=$(echo $focused_monitor | jq .dpmsStatus)
  if [[ $dpms_status == *true* ]]; then
    hyprctl dispatch dpms off $name
  else
    hyprctl dispatch dpms on $name
  fi
elif [[ $1 == *disable* ]]; then
  hyprctl keyword monitor $name,disable
elif [[ $1 == *enable* ]]; then
  if [[ $name == *eDP-1* ]]; then
    hyprctl keyword monitor HDMI-A-1,preferred,auto,1
  else
    hyprctl keyword monitor eDP-1,2880x1800@60,auto,2
  fi
fi


