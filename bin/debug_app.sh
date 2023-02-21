#!/bin/bash


echo "$(swaymsg -t get_tree | jq 'recurse(.nodes[]) | select(.marks != []) | if .app_id == null then .window_properties.class else .app_id end , .marks[0], .name')"
