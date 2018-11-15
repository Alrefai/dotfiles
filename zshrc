# Enable Shell Integration in iTerm2
test -e "${HOME}/.iterm2_shell_integration.zsh" &&\
source "${HOME}/.iterm2_shell_integration.zsh"

# Activate Antigen plugin manager
[ -f /usr/local/share/antigen/antigen.zsh ] && source ~/.zsh/antigenrc.zsh

# Aliases
[ -f ~/.zsh/aliases.zsh ] && source ~/.zsh/aliases.zsh

# Enable Vim mode key bindings
# bindkey -v
# spaceship_vi_mode_enable  # Enable Vim mode in spaceship theme

# FZF command-line fuzzy finder
[ -f ~/.fzf.zsh ] && source ~/.zsh/fzfrc.zsh

# awesome-terminal-fonts maps
# [ -f ~/.fonts ] && source ~/.fonts/*.sh

# Conda fix
[ -f /usr/local/miniconda3/etc/profile.d/conda.sh ] && \
  . /usr/local/miniconda3/etc/profile.d/conda.sh

# Settings
# ----- via sharpshark28/modern-terminal-workflow -----------------------------
# setopt auto_cd                    # Auto CD
# setopt correctall                 # Spellcheck / Typo Correction
# alias git status='nocorrect git status'

# -----

export TERM='screen-256color'     # Correct colors for Tmux and NeoVim
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

# added by travis gem
[ -f /Users/mohammed/.travis/travis.sh ] && \
  source /Users/mohammed/.travis/travis.sh || true
