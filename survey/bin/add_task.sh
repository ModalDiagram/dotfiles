#!/bin/bash

$ONEDRIVE/dotfiles/survey/bin/add
notify-send -t 5000 "inviata"
pkill -RTMIN+13 waybar
