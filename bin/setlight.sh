#!/bin/sh

focusedmonitor=$(hyprctl -j monitors | jq '.[] | select(.focused == true) | .name')
if [[ "$focusedmonitor" = *HDMI-A-1* ]]; then
  quantity=$(($2 * 5))
  ddcutil -d 1 setvcp 10 $1 $quantity
else
  brightnessctl set "$2%$1"
fi
