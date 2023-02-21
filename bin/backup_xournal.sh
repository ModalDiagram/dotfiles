#!/bin/bash

# la funzione controlla che non ci sia un'altra istanza di backup attiva.
# Se c'e', esiste il file /tmp/backup_xournal e al suo interno ha il PID del processo; controlla poi che il processo sia effettivamente attivo (potrebbe essere rimasto il file per un'interruzione improvvisa)
controlla_in_corso(){
  if [[ -f "$file" ]]; then
    # echo "file esiste"
    pid=$(cat "$file")
    if ps -p $pid >> /dev/null; then
      return 1 # torna 1 se il processo esiste, 0 altrimenti
    fi
  fi
  return 0
}

# la funziona copia il PID del processo nel file /tmp/backup_xournal
salva_pid(){
  echo $$ > $file;
}

# la funzione controlla se ci sono state modifiche ai file in $ONEDRIVE/write/3_anno/; se ci sono esporta il nuovo pdf del file modificato
controlla_modifiche(){
  while read -r line; do
    # echo $line
    line=${line%*:}
    if [[ -d "$line" ]]; then
      # echo "current directory $line"
      cwd=$line
    elif [[ -f $cwd/$line ]]; then
      file_dir=$cwd/$line
      # echo "$file_dir"
      if [[ "$file_dir" == *".xopp" ]]; then
        date=$(date -r "$file_dir" +"%s")
        # echo "trovato appunto $file_dir data $date,"
        if [[ $date -gt $current_time ]]; then
          echo "rilevata modifica a $file_dir";
          file_pdf=${file_dir%*.xopp}.pdf
          xournalpp "$file_dir" -p "$file_pdf"
          echo "creato $file_pdf"
        fi
      fi
    fi
    # echo "finito controllo"
    # echo "$line";
  done < <(ls -R $ONEDRIVE/write/3_anno/)
}

# trappo i segnali di CTRL-C e kill per controllare un'ultima volta
trap "echo controllo e termino; controlla_modifiche; exit" SIGTERM
trap "echo controllo e termino; controlla_modifiche; exit" SIGINT

# dichiaro variabili
anno_appunti=$ONEDRIVE/write/3_anno/
current_time=$(date +"%s")
i=0

# controllo se il processo esiste, altrimenti lo salvo
file=/tmp/backup_xournal
controlla_in_corso
if [[ $? -gt 0 ]]; then
  echo "processo esiste"
  exit
else
  salva_pid
fi

# finché non è interrotto controlla ogni secondo se ci sono segnali e ogni 60 secondi controlla se ci sono modifiche ai file (negli ultimi 60 secondi)
while true; do
  sleep 1
  i=$((i+1))
  # echo $i
  if [[ $((i % 60)) == 0 ]]; then
    # echo "controllo modifiche"
    controlla_modifiche
    current_time=$(date +"%s")
  fi
done
