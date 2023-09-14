#!/bin/bash

flag=$(cat "/tmp/my_lock.lock")
if [[ $flag -eq 1 ]]; then
  swaylock -f -c 000000
fi
