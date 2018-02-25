## Activate Antigen plugin manager
[ -f /usr/local/share/antigen/antigen.zsh ] && source ~/.zsh/antigenrc.zsh

# Tmux auto title
export DISABLE_AUTO_TITLE="true"

# ALIASES #
# ------- #

# Standard Shell
alias c='clear'
# Reload SHELL
alias r='exec $SHELL'
# alias l='ls -l'
# alias la='ls -al'
# alias bloat='du -k | sort -nr | more'

# Alias Vim to Neovim
# alias vim='nvim'

# Git
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

# gitignore.io API
function gi() { curl -L -s https://www.gitignore.io/api/$@ ;}

# tmux
alias attach='tmux attach-session -t'
alias switch='tmux switch-client -t'
alias tmk='tmux kill-session -t'
alias tls='tmux ls'
alias load='tmuxp load'
alias loadp='tmuxp load projects'

# Appended commands (always keep a new line at the end of this code):
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh          # FZF command-line fuzzy finder
[ -f ~/.fonts ] && source ~/.fonts/*.sh         # awesome-terminal-fonts maps
export LC_ALL=en_US.UTF-8    # Fix 'unknown locale: UTF-8' for python
export LANG=en_US.UTF-8      # Fix 'unknown locale: UTF-8' for python
export EDITOR="atom -nw"
export VISUAL="atom -nw"
export PATH="/usr/local/bin:$PATH"
export PATH="/usr/local/opt/curl/bin:$PATH"     # Homebrew curl
export PATH="/usr/local/opt/unzip/bin:$PATH"    # Homebrew unzip
export PATH="/usr/local/opt/sqlite/bin:$PATH"   # Homebrew sqlite
export PATH="/usr/local/opt/openssl/bin:$PATH"  # Homebrew openssl
export PATH="/usr/local/opt/icu4c/bin:$PATH"    # Homebrew icu4c
export PATH="/usr/local/opt/icu4c/sbin:$PATH"   # Homebrew icu4c
export PATH="/usr/local/opt/gettext/bin:$PATH"  # Homebrew gettext
