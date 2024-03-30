#!/usr/bin/env bash

# In this case the script exits with success (0) if the shiny process already exists
if [[ $1 == "exists" ]]; then
  if ! netstat -tulpn 2> /dev/null | grep -q 127.0.0.1:3838; then
    exit 1
  else
    exit 0
  fi
fi

# In this case the script closes the existing shiny process
if [[ $1 == "close" ]]; then
  process=$(netstat -tulpn 2>/dev/null | grep 127.0.0.1:3838)
  process=${process%\/R*}
  process=${process##*" "}
  kill $process && echo "Closed daemon"
  exit
fi

# Without any specified argument, the script launch the shiny daemon if it
# doesn't exists and opens a firefox tab
if ! netstat -tulpn 2> /dev/null | grep -q 127.0.0.1:3838; then
  echo "Running daemon"
  Rscript -e 'rmarkdown::run("~/.local/share/survey/bin/plot.Rmd", shiny_args = list(port = 3838))' &
  sleep 2
fi

firefox 127.0.0.1:3838
