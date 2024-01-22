#!/bin/sh

flag=$(cat "/tmp/my_lock.lock")
if [[ $flag -eq 1 ]]; then
  swaylock
fi
