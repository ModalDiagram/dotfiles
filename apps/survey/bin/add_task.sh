#!/bin/sh

survey_path=~/.local/share/survey/

in_count=0
in_mod=0
# Leggo i secondi della settimana e i secondi per task
{
  read in_count;
  read in_mod;
} < $survey_path/count.txt

# STEP 4. Aggiungo i secondi della task
new_total_count=$((in_count + in_mod))
echo "$new_total_count" > $survey_path/count.txt
echo "$in_mod" >> $survey_path/count.txt

# STEP 5. Leggo i dati della sessione corrente
count=0
cache_fin=0
cache_min=0
{
  read -r count
  read -r cache_fin
  read -r cache_min
} < $survey_path/timestamps.txt

# STEP 6. Data attuale
ts_now=$(date +"%s")

# STEP 7. Se e' passata mezz'ora dall'ultima task inizio una nuova sessione"
if [[ $((ts_now - cache_fin)) -lt 1800 ]]; then
  count=$((count + in_mod))
else
  count=0
  cache_min=$ts_now
fi

# STEP 8. Aggiorno i dati della sessione corrente
echo $count > $survey_path/timestamps.txt
echo $ts_now >> $survey_path/timestamps.txt
echo $cache_min >> $survey_path/timestamps.txt

echo $ts_now,$in_mod,$new_total_count >> $survey_path/data.txt

notify-send -t 5000 "inviata. nuovo ratio: $($survey_path/bin/evaluate_ratio.sh)"
