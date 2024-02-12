fir_open()
  {
    firefox file:///data/OneDrive/altri_programmi/guidelines/$1
  }

path=~/obsidian/main_vault/projects/oneforma/guidelines/

# you can pipe the list for wofi to display and search

# Present the user with a list of files in FILEPATH and let them select one
# Store their selection in FILE
file=$(ls $path | wofi -d)
echo $file
# Do whatever you want with FILE
firefox "file://$path/$file"
# Chiedo all'utente di scegliere la modalita'
entries="⇠ Search\n⇠ Autocomplete\n⇠ It local\n⇠ Ch local\n⇠ POI"

# selected=$(echo -e $entries|wofi --width 250 --height 210 --dmenu --cache-file /dev/null | awk '{print tolower($2)}')

# # echo "$selected"
# case $selected in
#   search)
#     fir_open maps_guidelines.pdf;;
#   autocomplete)
#     fir_open ac_guidelines.pdf;;
#   it)
#     fir_open it_guidelines.pdf;;
#   ch)
#     fir_open it_guidelines.pdf;;
#   poi)
#     fir_open poi_guidelines.pdf;;

# esac
