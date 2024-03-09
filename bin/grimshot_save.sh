#!/usr/bin/env bash

file=$(grimshot save area)
echo "$file" > /tmp/last_screenshot.txt
