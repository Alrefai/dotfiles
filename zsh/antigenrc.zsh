## Activate Antigen
source /usr/local/share/antigen/antigen.zsh

## Load Antigen bundles
antigen bundle zsh-users/zsh-completions
antigen use oh-my-zsh  # Load the oh-my-zsh's library
antigen bundle git
antigen bundle pip
antigen bundle docker
# antigen bundle dotenv
antigen bundle command-not-found
antigen bundle zsh-users/zsh-history-substring-search
antigen bundle zsh-users/zsh-autosuggestions
antigen bundle zsh-users/zsh-syntax-highlighting # must be the last bundle

# Tell Antigen that you're done.
antigen apply
