#!/bin/sh

ydotool mousemove -a 650 425
sleep 0.2
ydotool click 0xC0
~/.local/share/survey/bin/add
pkill -RTMIN+13 waybar
