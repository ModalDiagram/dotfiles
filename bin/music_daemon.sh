#!/bin/sh
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

pgid_from_pid() {
    local pid=$1
    ps -o pgid= "$pid" 2>/dev/null | egrep -o "[0-9]+"
}

pid="$$"
if [ "$pid" != "$(pgid_from_pid $pid)" ]; then
    exec setsid "$(readlink -f "$0")" "$@"
fi


trap 'exit; echo closed daemon' SIGTERM
trap 'echo stop' SIGINT

file=/tmp/music_daemon.lock

if [[ "$1" == "kill" ]]; then
  if [[ -f "$file" ]]; then
    pgid=$(cat /tmp/music_daemon.lock)
    while read -r pid; do
      kill $pid
    done < <(pgrep -g $pgid)
    # fi
  fi
  exit
fi

echo "started daemon"
echo $$ > "$file"

IFS=$'\t'
current_id=-1
while read -r playing artist title album; do
  if [[ "$playing" == ⏹️ ]]; then printf '{"text":}\n';
  else
    playing=${playing:1};
    artist=${artist:1};
    title=${title:1};
    album=${album:1};
    # echo "$playing";
    # echo "$artist";
    # echo "$title";
    if [[ current_id -eq "-1" ]]; then
      current_id=$(notify-send -p -a spotify -t 10000 "$title" "$artist - $album")
    else
      current_id=$(notify-send -p -r "$current_id" -a spotify -t 10000 "$title" "$artist - $album")
    fi
  fi
done < <(playerctl --follow metadata --player playerctld --format                        $':{{emoji(status)}}\t:{{markup_escape(artist)}}\t:{{markup_escape(title)}}\t:{{markup_escape(album)}}')

