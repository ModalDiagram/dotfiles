#!/bin/bash

YDOTOOL_SOCKET="$HOME/.ydotool_socket" ydotool mousemove -a 600 370
sleep 0.2
YDOTOOL_SOCKET="$HOME/.ydotool_socket" ydotool click 0xC0
$DOTFILES/survey/bin/add
notify-send -t 5000 "inviata"
pkill -RTMIN+13 waybar
