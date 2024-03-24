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

