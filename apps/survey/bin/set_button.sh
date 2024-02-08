#!/usr/bin/env bash

notify-send -t 3000 "Posiziona cursore sul bottone"
sleep 1
notify-send -t 2000 "2 secondi"
sleep 1
notify-send -t 1000 "1 secondi"
sleep 1
coord=$(hyprctl cursorpos) 
notify-send -t 3000 "Fatto"
screen_pos=($(hyprctl -j monitors |  jq '.[] | select(.focused == true) | .x, .y'))
x=${coord%,*}
y=${coord#*, }
if [[ -z $(hyprctl -j monitors |  jq '.[] | select(.focused == false)') ]]; then
  x=$((x - screen_pos[0]))
  y=$((y - screen_pos[1]))
fi
echo "$x $y"> /tmp/survey_cursor
