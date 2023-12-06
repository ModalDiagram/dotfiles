#!/bin/sh

survey_path=~/.local/share/survey/

# La funzione chiede il numero di secondi della modalita'
ask_seconds ()
{
  zenity --title "Inserisci valore: " --entry --text "Inserisci il numero di secondi: "
}

# Chiedo all'utente di scegliere la modalita'
entries="⇠ Custom\n⏾ VDAP (135s)\n⭮ Hours POI (150s)\n⇠ Address POI (120s)\n⇠ POI (480s)\n⇠ Images POI (60s)\n⇠ Search and AC (180s)"

selected=$(echo -e $entries|wofi -i --width 250 --height 210 --dmenu --cache-file /dev/null | awk '{print tolower($2)}')

# echo "$selected"
case $selected in
  search)
    new_mod="180";;
  vdap)
    new_mod="135";;
  hours)
    new_mod="150";;
  address)
    new_mod="120";;
  poi)
    new_mod="480";;
  images)
    new_mod="60";;

  custom)
    new_mod=$(ask_seconds);;
esac
echo $new_mod

in_count=0
read -r in_count < $survey_path/count.txt;
echo $in_count > $survey_path/count.txt
echo $new_mod >> $survey_path/count.txt
pkill -RTMIN+13 waybar
