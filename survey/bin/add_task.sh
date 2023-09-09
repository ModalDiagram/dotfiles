#!/bin/bash

ydotool mousemove -a 650 425
sleep 0.2
ydotool click 0xC0
$DOTFILES/survey/bin/add
notify-send -t 5000 "inviata"
pkill -RTMIN+13 waybar
