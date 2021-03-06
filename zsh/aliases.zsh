# ---- My aliases ------------------------------------------------------

alias vi='nvim'
alias gla='git-foresta --all --style=15 | less -RSX'
alias jn='jupyter notebook'
alias jnn='jupyter nteract'
alias treee='tree -CI node_modules'
alias nowjam='now -A now-prod.json && now alias -A now-prod.json'
alias upgradeZsh='antigen update && antigen reset && exec $SHELL'
alias viHistory='nvim ~/.zsh_history'
alias cat='ccat'
alias tarx='tar -xzvf'
alias k='kubectl'
alias gc='git commit'

# gRenameComp() {
#   for file in $(git ls-files | rg 'components/\w+?.js');
#   git mv $file $(echo $file | sed -e 's/\(components\/[^/]*\).js/\1.tsx/')
# }

## Using FZF to Enhance Git
### Rename multiple files' extension in a git repo
### 1. Pass desired new file extension as an argument (e.g. `fgm tsx`)
### 2. Selelct files from fzf list
fgm() {
  if [ -z "$1" ]; then
    echo "Pass new file extension as an argument"
  else
    for file in $(git ls-files | fzf); git mv ${file} ${file/%.*/.$1}
  fi
}

alias fgl="git ls-files -m -o --exclude-standard | fzf"
alias fgla="git ls-files | fzf"
alias fga='git add -p `fgl`'
# * https://spin.atomicobject.com/2018/04/05/fuzzy-find-git-add/
# alias fza="git ls-files -m -o --exclude-standard | fzf -m --print0 | xargs -0 -o -t git add -p"


## Force Plex to scan media
alias pms='"/Applications/Plex Media Server.app/Contents/MacOS/Plex Media Scanner"'

## Clear k8s current context
alias kubeclr='sed -i"" -e"s/^current-context:.*$/current-context:/" ~/.kube/config'

## open nnn file browswer in detail view mode
alias n='nnn -d'

## Aliases to protect against deletion
alias rm='rm -i'
alias rd='rm -ri'

## tmux
alias loadp='tmuxp load projects'

## alias git=hub
[ -f /usr/local/bin/hub ] && eval "$(hub alias -s)"

## gitignore.io API
function gi() { curl -L -s https://www.gitignore.io/api/$@ ;}

# ---- http://brettterpstra.com ------------------------------------------------

function ql { qlmanage -p &>/dev/null $1 & }

# cd to the path of the front Finder window
cdf() {
	target=`osascript -e 'tell application "Finder" to if (count of Finder windows) > 0 then get POSIX path of (target of front Finder window as text)'`
	if [ "$target" != "" ]; then
		cd "$target"; pwd
	else
		echo 'No Finder window found' >&2
	fi
}

# You can also create an alias to do the reverse
alias f='open -a Finder ./'

# ---- keiththomps/dotfiles/shell_defaults ------------------------------------

## Standard Shell
alias c='clear'
alias r='exec $SHELL'  # Reload SHELL

## Alias Vim to Neovim
# alias vim='nvim'

## Git
alias g='git status -s'
# alias ga='git add'
alias gb='git branch'
# alias gc='git commit -m'
# alias gca='git commit -am'
alias gco='git checkout'
alias gcob='git checkout -b'
alias grpr='git remote prune origin'
alias gl='git log --oneline --graph'
# alias gla='git log --oneline --graph --all'

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
  cd ~/.dotfiles && git pull --ff-only && ./install -q
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

# ---- bag-man/dotfiles/bashrc ------------------------------------------------

alias diff="git difftool"
alias show="git showtool"

## Harnesses the power of fzf and rg to let you edit as quickly as possible
# sf() {
#   if [ "$#" -lt 1 ]; then echo "Supply string to search for!"; return 1; fi
#   printf -v search "%q" "$*"
#   include="yml,js,json,php,md,styl,pug,jade,html,config,py,cpp,c,go,hs,rb,conf,fa,lst"
#   exclude=".config,.git,node_modules,vendor,build,yarn.lock,*.sty,*.bst,*.coffee,dist"
#   rg_command='rg --column --line-number --no-heading --fixed-strings --ignore-case --no-ignore --hidden --follow --color "always" -g "*.{'$include'}" -g "!{'$exclude'}/*"'
#   files=`eval $rg_command $search | fzf --ansi --multi --reverse | awk -F ':' '{print $1":"$2":"$3}'`
#   [[ -n "$files" ]] && ${EDITOR:-vim} $files
# }

## checkout selected commit
# Renamed function from `tc` to `gcoc`
gcoc() {
  hash=$(git log --color=always --format="%C(auto)%h%d %s %C(blue)%C(bold)%cr" "$@" | fzf | awk '{print $1}')
  git checkout $hash
}

## Open selected commit on github
# Added `$` at the last sed command to trim `.git` only
# Modified the code for https github urls
# Replaced `xdg-open` with `open`
# Renamed function from `gc` to `gopc`
# Changed color from black to blue
gopen() {
    project=$(git config --local remote.origin.url | sed s/\.git$//)
    url="$project/commit/$1"
    open $url
    # project=$(git config --local remote.origin.url | sed s/git@github.com\:// | sed s/\.git//)
    # url="http://github.com/$project/commit/$1"
    # xdg-open $url
}

gopc() {
    hash=$(git log --color=always --format="%C(auto)%h%d %s %C(blue)%C(bold)%cr" "$@" | fzf | awk '{print $1}')
    gopen $hash
}

## Show diffirences in a commit via FZF selection
# Deleted xclip command
# Renamed function from `fzf_log` to `gflog`
# Changed color from black to blue
gflog() {
    hash=$(git log --color=always --format="%C(auto)%h%d %s %C(blue)%C(bold)%cr" "$@" | fzf | awk '{print $1}')
    echo $hash
    git showtool $hash
}
