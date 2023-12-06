#!/bin/sh

survey_path=~/.local/share/survey/

num=0
mod=0
# Leggo tempo e modalita' correnti
{
  read -r num
  read -r mod
} < $survey_path/count.txt
# echo $val_curr

# Chiedo il nuovo valore di tempo
new_val=$(zenity --title "Inserisci valore: " --entry --text "Secondi attuali: $num. Inserisci il nuovo valore:")

# Sovrascrivo il conto
if [[ -n "$new_val" ]]; then
  echo "$new_val" > $survey_path/count.txt
  echo "${mod}" >> $survey_path/count.txt
fi
pkill -RTMIN+13 waybar
