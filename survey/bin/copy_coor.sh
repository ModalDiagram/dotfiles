#!/bin/bash

string=$(wl-paste)

# echo "${string#*:}"
if [[ "$string" == "Location:"* ]]; then
  wl-copy "${string#*:}"
fi
