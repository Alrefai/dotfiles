# Activate Antigen plugin manager
[ -f /usr/local/share/antigen/antigen.zsh ] && source ~/.zsh/antigenrc.zsh

# Aliases
[ -f ~/.zsh/aliases.zsh ] && source ~/.zsh/aliases.zsh

# FZF command-line fuzzy finder
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# awesome-terminal-fonts maps
[ -f ~/.fonts ] && source ~/.fonts/*.sh

# Exports
export DISABLE_AUTO_TITLE="true"  # Tmux auto title
export LC_ALL=en_US.UTF-8         # Fix 'unknown locale: UTF-8' for python
export LANG=en_US.UTF-8           # Fix 'unknown locale: UTF-8' for python
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
