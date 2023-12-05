#!/bin/bash

mapfile -t files < <(fzf --filter=sh)
echo "${files[@]}"
