#!/bin/bash

ydotool mousemove -a 600 370
sleep 0.2
ydotool click 0xC0
$ONEDRIVE/dotfiles/survey/bin/add
notify-send -t 5000 "inviata"
pkill -RTMIN+13 waybar
