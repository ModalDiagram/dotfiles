#!/bin/sh

survey_path=~/.local/share/survey/

sleep 0.15
export LC_NUMERIC="en_US.UTF-8"
text=""
num=0
mode=0
# Leggo i secondi fatti nella settimana e i secondi per task
{
  read -r num
  read -r mode
} < $survey_path/count.txt

# Conto le ore fatte e se diverse da 0 le inserisco
hours=$((num / 3600))
if [[ $hours -ne 0 ]]; then
  text+=${hours}h
fi

# Conto i minuti e li inserisco
minutes=$((num % 3600))
minutes=$((minutes / 60 ))
text+=${minutes}m

# Prendo il ratio e formatto
ratio=$($survey_path/bin/evaluate_ratio.sh)
tooltip="Mode: ${mode}s. Ratio: ${ratio}."

if [[ $(cat $survey_path/obfuscate.txt) == "yes" ]]; then
printf '{"text":"||||","tooltip":"Time: %s, %s","class":"%s","percentage":%s}\n' \
			"$text" "$tooltip" "num" "$num"
exit
fi

printf '{"text":"%s","tooltip":"%s","class":"%s","percentage":%s}\n' \
			"$text" "$tooltip" "num" "$num"
