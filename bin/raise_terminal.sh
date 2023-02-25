file=/home/sandro0198/.cache/floating_terminal.txt
if [[ ! -f $file ]]; then
  create_floating_terminal.sh
else
  pid=$(cat $file)
  ps -p $pid >> /dev/null || create_floating_terminal.sh
fi

swaymsg [title="floating_terminal"] scratchpad show
