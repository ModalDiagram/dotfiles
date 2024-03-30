#!/usr/bin/env bash

obfuscate_file=~/.local/share/survey/obfuscate.txt

if [[ ! -f $obfuscate_file ]]; then
  echo "no" > $obfuscate_file
else
  flag=$(cat $obfuscate_file)
  if [[ $flag == "yes" ]]; then
    echo "no" > $obfuscate_file
  else
    echo "yes" > $obfuscate_file
  fi
fi

pkill -RTMIN+13 waybar
