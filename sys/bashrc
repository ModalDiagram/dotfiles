#
# ~/.bashrc
#

# If not running interactively, don't do anything
# [[ $- != *i* ]] && return

# [[ -f ~/.welcome_screen ]] && . ~/.welcome_screen

# _set_liveuser_PS1() {
#     PS1='[\u@\h \W]\$ '
#     if [ "$(whoami)" = "liveuser" ] ; then
#         local iso_version="$(grep ^VERSION= /usr/lib/endeavouros-release 2>/dev/null | cut -d '=' -f 2)"
#         if [ -n "$iso_version" ] ; then
#             local prefix="eos-"
#             local iso_info="$prefix$iso_version"
#             PS1="[\u@$iso_info \W]\$ "
#         fi
#     fi
# }
# _set_liveuser_PS1
# unset -f _set_liveuser_PS1

# ShowInstallerIsoInfo() {
#     local file=/usr/lib/endeavouros-release
#     if [ -r $file ] ; then
#         cat $file
#     else
#         echo "Sorry, installer ISO info is not available." >&2
#     fi
# }

function _update_ps1() {
    PS1=$(powerline-shell $?)
}

if [[ $TERM != linux && ! $PROMPT_COMMAND =~ _update_ps1 ]]; then
    PROMPT_COMMAND="_update_ps1; $PROMPT_COMMAND"
fi

alias ls='ls --color=auto'
alias ll='ls -lav --ignore=..'   # show long listing of all except ".."
alias l='ls -lav --ignore=.?*'   # show long listing but no hidden dotfiles except "."

[[ "$(whoami)" = "root" ]] && return

[[ -z "$FUNCNEST" ]] && export FUNCNEST=100          # limits recursive functions, see 'man bash'

## Use the up and down arrow keys for finding a command in history
## (you can write some initial letters of the command first).
bind '"\e[A":history-search-backward'
bind '"\e[B":history-search-forward'

################################################################################
## Some generally useful functions.
## Consider uncommenting aliases below to start using these functions.
##
## October 2021: removed many obsolete functions. If you still need them, please look at
## https://github.com/EndeavourOS-archive/EndeavourOS-archiso/raw/master/airootfs/etc/skel/.bashrc


#------------------------------------------------------------

## Aliases for the functions above.
## Uncomment an alias if you want to use it.
##

# alias pacdiff=eos-pacdiff
################################################################################



export ONEDRIVE=/data/OneDrive/
export ANNO=$ONEDRIVE/libri/3_anno/
export PROG=$ONEDRIVE/personali/programmazione/rust/
export PATH=$PATH:/usr/share/applications
shopt -s direxpand
alias anaconda='source /home/sandro0198/.conda_bashrc'
export QT_QPA_PLATFORMTHEME=qt5ct
export XDG_CURRENT_DESKTOP=sway
export JAVA_HOME=/home/sandro0198/altre_app/jdk-17.0.2/
export DOTFILES=/data/dotfiles/
alias onesync='systemctl --user restart onedrive'

#---------------------- fzf options ----------------------
export FZF_DEFAULT_OPTS="--bind=ctrl-j:down,ctrl-k:up"


[ -f ~/.fzf.bash ] && source ~/.fzf.bash


# Uso fd per completare nvim **
_fzf_compgen_path() {
  fd --type f --follow . "$1"
}

# Uso fd per completare cd **
_fzf_compgen_dir() {
  fd --type d --follow . "$1"
}
