#!/usr/bin/env bash

monitors=("eDP-1" "HDMI-A-1")
focusedmonitor=$(hyprctl -j monitors | jq '.[] | select(.focused == true) | .name')
focused=false
for monitor in "${monitors[@]}"; do
  if $focused; then
    hyprctl dispatch focusmonitor $monitor
    exit
  fi
  # echo "$focusedmonitor $monitor"
  if [[ "$focusedmonitor" == *$monitor* ]]; then
    focused=true
  fi
done

hyprctl dispatch focusmonitor ${monitors[0]}
