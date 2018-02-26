# ---- My aliases ------------------------------------------------------

## Aliases to protect against deletion
alias rm='rm -i'
alias rmd='rm -ri'
alias rmdf='rm -rf'

## tmux
alias loadp='tmuxp load projects'

## alias git=hub
[ -f /usr/local/bin/hub ] && eval "$(hub alias -s)"

## gitignore.io API
function gi() { curl -L -s https://www.gitignore.io/api/$@ ;}

# ---- keiththomps/dotfiles/shell_defaults ------------------------------------

## Standard Shell
alias c='clear'
alias r='exec $SHELL'  # Reload SHELL

## Alias Vim to Neovim
# alias vim='nvim'

## Git
alias g='git status -s'
alias ga='git add'
alias gb='git branch'
alias gc='git commit -m'
alias gca='git commit -am'
alias gco='git checkout'
alias gcob='git checkout -b'
alias grpr='git remote prune origin'
alias gl='git log --oneline --graph'
alias gla='git log --oneline --graph --all'

## tmux
alias attach='tmux attach-session -t'
alias switch='tmux switch-client -t'
alias tmk='tmux kill-session -t'
alias tls='tmux ls'
alias load='tmuxp load'

# ---- anishathalye/dotfiles/shell/aliases.sh ---------------------------------

## Aliases to protect against overwriting
alias cp='cp -i'
alias mv='mv -i'

## Update dotfiles
dfu() {
    (
        cd ~/.dotfiles && git pull --ff-only && ./install -q
    )
}

## cd to git root directory
alias cdgr='cd "$(git root)"'

## Create a directory and cd into it
mcd() {
    mkdir "${1}" && cd "${1}"
}

# ---- webpro/dotfiles/system/.alias && ../.function.macos --------------------

alias rr="rm -rf"

## Open man page as PDF
manpdf() {
  man -t "$1" | open -f -a /Applications/Preview.app/
}

## Open query in Dash app
dash() {
  case $# in
    1) QUERY="$1";;
    2) QUERY="$1:$2";;
    *) echo "Usage: dash [docset] query"; return 1;
  esac
  open "dash://$QUERY"
}
