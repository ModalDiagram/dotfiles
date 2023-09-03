#!/bin/bash
# ./music_daemon.sh launches the daemon
# While it is running, it sends notification everytime the playing song changes
# (actually it saves the id of the notification so that it can replace the
# same one notification).
#
# At the start, it writes its pid in $file, so that
# ./music_daemon.sh kill
# kills the daemon.
#
# This is useful when you change song from outside Spotify but don't always
# want notifications

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
current_id=-1
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
    if [[ current_id -eq "-1" ]]; then
      current_id=$(notify-send -p -a spotify -t 10000 "Playing $title by $artist")
    else
      notify-send -r "$current_id" -a spotify -t 10000 "Playing $title by $artist"
    fi
  fi
done < <(playerctl --follow metadata --player playerctld --format                        $':{{emoji(status)}}\t:{{markup_escape(artist)}}\t:{{markup_escape(title)}}')
