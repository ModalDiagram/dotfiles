#!/bin/sh

survey_path=~/.local/share/survey/

# Ripristino la sessione azzerando il tempo della sessione e il tempo dell'ultima task
echo 0 > $survey_path/timestamps.txt
echo "$(date +"%s")" >> $survey_path/timestamps.txt
echo "$(date +"%s")" >> $survey_path/timestamps.txt
pkill -RTMIN+13 waybar
