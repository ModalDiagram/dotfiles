#!/usr/bin/env bash

possible_sinks=(60 71)

if [[ -f /tmp/my_sink ]]; then
  current_sink=$(cat /tmp/my_sink)
  setsync=false
  for sink in "${possible_sinks[@]}"; do
    if $setsync; then
      wpctl set-default "$sink"
      echo "$sink" > /tmp/my_sink
      exit
    fi
    if [[ "$sink" == "$current_sink" ]]; then
      setsync=true
    fi
  done
fi

wpctl set-default "${possible_sinks[0]}"
echo "${possible_sinks[0]}" > /tmp/my_sink
