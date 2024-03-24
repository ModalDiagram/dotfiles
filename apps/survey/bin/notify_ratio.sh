#!/bin/sh

ratio=$(~/.local/share/survey/bin/evaluate_ratio.sh)
notify-send -t 2000 "ratio: $ratio"
