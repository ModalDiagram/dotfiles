#!/bin/bash

window=$(getfocusedwindow)
if [[ "$window" == *"$1"* ]]; then
  exit 0
else exit 1
fi
