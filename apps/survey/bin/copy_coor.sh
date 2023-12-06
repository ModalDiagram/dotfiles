#!/bin/sh

string=$(wl-paste)

# echo "${string#*:}"
if [[ "$string" == *:\ * ]]; then
  wl-copy "${string#*:\ }"
  exit
fi
if [[ "$string" == *"or:" ]]; then
  new_string=${string%*\ or:}
  wl-copy "${new_string#*can\ be\ }"
  exit
fi
