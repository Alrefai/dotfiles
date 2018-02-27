# Enable Shell Integration in iTerm2
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# Activate Antigen plugin manager
[ -f /usr/local/share/antigen/antigen.zsh ] && source ~/.zsh/antigenrc.zsh

# Aliases
[ -f ~/.zsh/aliases.zsh ] && source ~/.zsh/aliases.zsh

# FZF command-line fuzzy finder
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
# ---- http://owen.cymru/fzf-ripgrep-navigate-with-bash-faster-than-ever-before
export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow -g "!{.git,node_modules}/*" 2> /dev/null'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# awesome-terminal-fonts maps
[ -f ~/.fonts ] && source ~/.fonts/*.sh

# Settings
export DISABLE_AUTO_TITLE="true"  # Tmux auto title
export LC_ALL=en_US.UTF-8         # Fix 'unknown locale: UTF-8' for python
export LANG=en_US.UTF-8           # Fix 'unknown locale: UTF-8' for python
export EDITOR="atom -nw"
export VISUAL="atom -nw"

# PATH
[ -f ~/.zsh/path.zsh ] && source ~/.zsh/path.zsh
