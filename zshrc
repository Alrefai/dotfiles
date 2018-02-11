 source /usr/local/share/antigen/antigen.zsh

# Load the oh-my-zsh's library.
antigen use oh-my-zsh

# Bundles from the default repo (robbyrussell's oh-my-zsh).
antigen bundle git
# antigen bundle heroku
antigen bundle pip
# antigen bundle lein
antigen bundle command-not-found

# Syntax highlighting bundle.
antigen bundle zsh-users/zsh-syntax-highlighting
antigen bundle zsh-users/zsh-completions
antigen bundle zsh-users/zsh-history-substring-search
antigen bundle zsh-users/zsh-autosuggestions

# Load the theme.
antigen theme https://github.com/denysdovhan/spaceship-prompt spaceship
# antigen theme maximbaz/spaceship-prompt spaceship
# antigen theme dracula/zsh dracula

# Tell Antigen that you're done.
antigen apply

SPACESHIP_TIME_SHOW="true"
SPACESHIP_TIME_COLOR="8"
SPACESHIP_TIME_FORMAT="%D{%F} %*"
# SPACESHIP_PROMPT_FIRST_PREFIX_SHOW="true"
SPACESHIP_DIR_COLOR="blue"
SPACESHIP_DIR_TRUNC="0"
# SPACESHIP_DIR_TRUNC_REPO="false"
SPACESHIP_GIT_BRANCH_COLOR="cyan"
# SPACESHIP_PROMPT_SEPARATE_LINE="false"

### [keiththomps/dotfiles](https://github.com/keiththomps/dotfiles/blob/master/.zshrc)
# Tmux auto title
export DISABLE_AUTO_TITLE="true"

# ALIASES #
###########

# Standard Shell
alias c='clear'
# alias l='ls -l'
# alias la='ls -al'
# alias bloat='du -k | sort -nr | more'

# Alias Vim to Neovim
# alias vim='nvim'

# Bundle Exec
# alias be="bundle exec"

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

# tmux
alias attach='tmux attach-session -t'
alias switch='tmux switch-session -t'
alias tmk='tmux kill-session -t'
alias tls='tmux ls'
alias load='tmuxp load'

# Flush DNS Cache
alias dnsflush='dscacheutil -flushcache; sudo killall -HUP mDNSResponder'

# Reload SHELL
alias r='exec $SHELL'

### End of section

# Appended commands (always keep a new line at the end of this code):
export PATH="/usr/local/opt/curl/bin:$PATH" # brew curl
export PATH="/usr/local/opt/unzip/bin:$PATH" # brew unzip
export PATH="/usr/local/opt/sqlite/bin:$PATH" # brew sqlite
export PATH="/usr/local/opt/openssl/bin:$PATH" # brew openssl
export PATH="/usr/local/opt/icu4c/bin:$PATH" # brew icu4c
export PATH="/usr/local/opt/icu4c/sbin:$PATH" # brew icu4c
