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

export PATH="/usr/local/opt/curl/bin:$PATH"
SPACESHIP_TIME_SHOW="true"
SPACESHIP_TIME_COLOR="8"
SPACESHIP_TIME_FORMAT="%D{%F} %*"
# SPACESHIP_PROMPT_FIRST_PREFIX_SHOW="true"
SPACESHIP_DIR_COLOR="blue"
SPACESHIP_DIR_TRUNC="0"
# SPACESHIP_DIR_TRUNC_REPO="false"
SPACESHIP_GIT_BRANCH_COLOR="cyan"
# SPACESHIP_PROMPT_SEPARATE_LINE="false"