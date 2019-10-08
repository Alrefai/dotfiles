# Enable Shell Integration in iTerm2
test -e "$HOME/.iterm2_shell_integration.zsh" &&\
source "$HOME/.iterm2_shell_integration.zsh"

# Activate Antigen plugin manager
[ -f /usr/local/share/antigen/antigen.zsh ] && source ~/.zsh/antigenrc.zsh

# Aliases
[ -f ~/.zsh/aliases.zsh ] && source ~/.zsh/aliases.zsh

# Enable Vim mode key bindings
bindkey -v

# FZF command-line fuzzy finder
[ -f ~/.fzf.zsh ] && source ~/.zsh/fzfrc.zsh

# awesome-terminal-fonts maps
# [ -f ~/.fonts ] && source ~/.fonts/*.sh

# Settings
setopt HIST_IGNORE_SPACE    # Don't save to histor if command begin with a space
set -o ignoreeof            # Disable closing shell with C-d

# ----- via sharpshark28/modern-terminal-workflow ------------------------------
# setopt auto_cd                    # Auto CD
# setopt correctall                 # Spellcheck / Typo Correction
# alias git status='nocorrect git status'

# -----

export TERM="screen-256color"     # Correct colors for Tmux and NeoVim
export DISABLE_AUTO_TITLE="true"  # Tmux auto title
export LC_ALL=en_US.UTF-8         # Fix 'unknown locale: UTF-8' for python
export LANG=en_US.UTF-8           # Fix 'unknown locale: UTF-8' for python
export EDITOR="nvim"
export VISUAL="$EDITOR"

# PATH
[ -f ~/.zsh/path.zsh ] && source ~/.zsh/path.zsh

# Set Spaceship ZSH as a prompt
autoload -U promptinit; promptinit
prompt spaceship                  # Managed by yarn global
SPACESHIP_DIR_COLOR="blue"
SPACESHIP_GIT_BRANCH_COLOR="cyan"
SPACESHIP_VI_MODE_COLOR="magenta"
SPACESHIP_CHAR_SYMBOL="❯ "
SPACESHIP_VI_MODE_SUFFIX="❯"
SPACESHIP_VI_MODE_INSERT="❯"
SPACESHIP_VI_MODE_NORMAL="❮"
spaceship_vi_mode_enable  # Enable Vim mode in spaceship theme

# added by travis gem
[ -f ~/.travis/travis.sh ] && source "$HOME/.travis/travis.sh" || true
