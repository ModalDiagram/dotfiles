#!/bin/bash

ratio=$($DOTFILES/survey/bin/ratio)
notify-send -t 2000 "ratio: $ratio"
