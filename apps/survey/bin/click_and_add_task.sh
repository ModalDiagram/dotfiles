#!/usr/bin/env bash

if [[ -f /tmp/survey_cursor ]]; then
  ydotool mousemove -a $(cat /tmp/survey_cursor)
else
  notify-send -t 3000 "Set button position in menu"
fi
sleep 0.2
ydotool click 0xC0
~/.local/share/survey/bin/add_task.sh
~/.local/share/wl_fix/module_wl.sh dismiss
pkill -RTMIN+13 waybar
