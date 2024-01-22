#!/bin/sh

flag=$(cat "/tmp/my_lock.lock")

if [[ $1 == "toggle" ]]; then
  if [[ $flag -eq 1 ]]; then
    echo 0 > "/tmp/my_lock.lock";
  else
    echo 1 > "/tmp/my_lock.lock";
  fi
  sleep 0.1
  pkill -RTMIN+13 waybar
  exit
fi

if [[ $flag -eq 1 ]]; then
  echo "󰍁";
else
  echo "󰌿";
fi
