#!/usr/bin/env bash

lock="/tmp/wl_fix.lock"

if [[ $1 == "toggle" ]]; then
  ~/.local/share/wl_fix/copy_notification.sh &
fi

if [[ $1 == "dismiss" ]]; then
  open_notifications=($(makoctl list | jq '.data | .[].[] | select(."app-name".data=="wlfix") | .id.data'))
  for id in "${open_notifications[@]}"; do
    makoctl dismiss -n "$id"
  done
fi

if [[ -f $lock ]]; then
  echo "";
else
  echo "󱤹";
fi

pkill -RTMIN+11 waybar
