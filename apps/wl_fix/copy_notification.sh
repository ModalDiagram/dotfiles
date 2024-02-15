#!/usr/bin/env bash

# content=$(wl-paste)

repeat_notification () {
  content=$1
  while true; do
    result=$(notify-send -a wlfix -A wl-copy="a" "$content")
    if [[ -n "$result" ]]; then
      wl-copy "$content"
    else
      break
    fi
  done
}

pgid_from_pid() {
    local pid=$1
    ps -o pgid= "$pid" 2>/dev/null | egrep -o "[0-9]+"
}

pid="$$"
if [ "$pid" != "$(pgid_from_pid $pid)" ]; then
    exec setsid "$(readlink -f "$0")" "$@"
fi

file=/tmp/wl_fix.lock

if [[ -f "$file" ]]; then
  pgid=$(cat $file)
  while read -r pid; do
    kill $pid
  done < <(pgrep -g $pgid)
  rm "$file"
  open_notifications=($(makoctl list | jq '.data | .[].[] | select(."app-name".data=="wlfix") | .id.data'))
  for id in "${open_notifications[@]}"; do
    makoctl dismiss -n "$id"
  done
  exit
fi

echo $$ > "$file"

while read -r line; do
  content=$(wl-paste)
  if [[ -z $(makoctl list | jq --arg name "$content" '.data | .[].[] | select(.summary.data==$name)') ]]; then
    repeat_notification "$(wl-paste)" &
  fi
done < <(wl-paste --watch echo)
