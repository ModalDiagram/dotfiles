#!/bin/bash

file=/tmp/music_daemon.lock

if [[ "$1" == "kill" ]]; then
  if [[ -f "$file" ]]; then
    # echo "file esiste"
    pid=$(cat "$file")
    if ps -p "$pid" >> /dev/null; then
      kill "$pid"
    fi
  fi
  exit
fi

echo $$ > "$file"

IFS=$'\t'
# if [[ "$status" == "Stopped" ]]; then printf ""; exit; fi
while read -r playing artist title; do
  if [[ "$playing" == ⏹️ ]]; then printf '{"text":}\n';
  else
    playing=${playing:1};
    artist=${artist:1};
    title=${title:1};
    # echo "$playing";
    # echo "$artist";
    # echo "$title";
    notify-send -t 10000 "Playing $title by $artist"
    # text="$playing $title"
    # tooltip="$text $artist"
    #   printf '{"text":"%s","tooltip":"%s"}\n' \
    #     "$text" "$tooltip"
  fi
done < <(playerctl --follow metadata --player playerctld --format                        $':{{emoji(status)}}\t:{{markup_escape(artist)}}\t:{{markup_escape(title)}}')
