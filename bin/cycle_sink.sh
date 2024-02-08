#!/usr/bin/env bash

set_synk () {
  sink_id=$(wpctl status | grep -Po "(?<= {6})(.*)(?=\. $1)")
  wpctl set-default "$sink_id"
}

possible_sinks=("Family 17h/19h HD Audio Controller Speaker" "Rembrandt Radeon High Definition Audio Controller HDMI / DisplayPort 2")

if [[ -f /tmp/my_sink ]]; then
  current_sink=$(cat /tmp/my_sink)
  flag=false
  for sink in "${possible_sinks[@]}"; do
    if $flag; then
      set_synk "$sink"
      echo "$sink" > /tmp/my_sink
      exit
    fi
    if [[ "$sink" == "$current_sink" ]]; then
      flag=true
    fi
  done
fi

set_synk "${possible_sinks[0]}"
echo "${possible_sinks[0]}" > /tmp/my_sink
