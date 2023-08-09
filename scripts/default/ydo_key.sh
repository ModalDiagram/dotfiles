#!/bin/bash

comb=$(get_app_bindings $1)
if [[ "$comb" == exec:* ]]; then
  echo "custom"
  eval "${comb#*exec:}"
else
  YDOTOOL_SOCKET="$HOME/.ydotool_socket" ydotool key $comb
fi
