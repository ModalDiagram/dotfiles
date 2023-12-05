#!/bin/bash

create_and_show(){
  create_floating_terminal.sh;
  sleep 0.3
}

file=/home/sandro0198/.cache/floating_terminal.txt
if [[ ! -f $file ]]; then
  create_and_show
else
  pid=$(cat $file)
  ps -p "$pid" >> /dev/null || create_and_show
fi

swaymsg [title="floating_terminal"] scratchpad show
