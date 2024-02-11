#!/usr/bin/env bash

pid=$(hyprctl -j clients | jq --arg title "$1" '.[] | select(.initialTitle == $title) | .pid')
hyprctl dispatch focuswindow "pid:$pid"
