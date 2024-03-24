#!/bin/sh

ts_now=$(date +"%s")
count=0
cache_min=0

# Leggo i dati della sessione corrente
{
  read -r count
  read -r
  read -r cache_min
} < ~/.local/share/survey/timestamps.txt

# Calcolo il rapporto di tempo impiegato rispetto a quello previsto (idealmente 1)
ratio=$(echo "$count / ($ts_now - $cache_min)" | bc -l)
LC_NUMERIC="en_US.UTF-8" printf "%.2f" "$ratio"
