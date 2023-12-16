#!/bin/sh

ydotool mousemove -a 620 400
sleep 0.2
ydotool click 0xC0
~/.local/share/survey/bin/add
pkill -RTMIN+13 waybar
