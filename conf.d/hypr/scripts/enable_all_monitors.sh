#!/usr/bin/env bash

# enable disabled monitors
declare -A monitors_config=(["eDP-1"]="eDP-1,2880x1800@60,auto,2" ["HDMI-A-1"]="HDMI-A-1,preferred,auto,auto")
while read -r monitor; do
  echo $monitor
  monitor=${monitor#*\"}
  monitor=${monitor%\"*}
  hyprctl keyword monitor ${monitors_config[$monitor]}
done < <(hyprctl -j monitors all | jq '.[] | select(.disabled == true) | .name')

# turn on monitors that are powered off
while read -r monitor; do
  echo $monitor
  monitor=${monitor#*\"}
  monitor=${monitor%\"*}
  hyprctl dispatch dpms on $monitor
done < <(hyprctl -j monitors all | jq '.[] | select(.dpmsStatus == false) | .name')
