#!/usr/bin/env bash

bin_path=~/.local/share/survey/bin/

entries="⇠ Reset session\n⏾ Scegli attività\n⭮ Modifica manualmente\nImposta Submit Rating\nOpen Guidelines\nMonthly Statement"

if $bin_path/plot_monthly_statement.sh "exists"; then
  entries="$entries\nClose Monthly Statement"
fi

selected=$(echo -e $entries|wofi --insensitive --width 250 --height 210 --dmenu --cache-file /dev/null | awk '{print tolower($2)}')

# echo "$selected"
case $selected in
  reset)
    $bin_path/reset_session.sh;;
  scegli)
    $bin_path/choose_mode.sh;;
  modifica)
    $bin_path/change_total_seconds.sh;;
  submit)
    $bin_path/set_submit_button.sh;;
  guidelines)
    $bin_path/choose_guidelines.sh;;
  statement)
    $bin_path/plot_monthly_statement.sh;;
    # python ~/.local/share/survey/python/plot_month_hour.py;;
  monthly)
    $bin_path/plot_monthly_statement.sh "close";;
esac
