#!/bin/bash

file=/home/sandro0198/.cache/floating_terminal.txt
if [[ -f $file ]]; then
  pid=$(cat $file)
  ps -p "$pid" >> /dev/null && exit
fi
alacritty -t floating_terminal &
echo $! > $file

