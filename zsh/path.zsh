# Load Homebrew binaries before system ones
export PATH="/usr/local/opt/curl/bin:$PATH"
export PATH="/usr/local/opt/unzip/bin:$PATH"
export PATH="/usr/local/opt/sqlite/bin:$PATH"
export PATH="/usr/local/opt/openssl/bin:$PATH"
export PATH="/usr/local/opt/icu4c/bin:$PATH"
export PATH="/usr/local/opt/icu4c/sbin:$PATH"
export PATH="/usr/local/opt/gettext/bin:$PATH"
export PATH="/usr/local/opt/gnu-sed/libexec/gnubin:$PATH"
export MANPATH="/usr/local/opt/gnu-sed/libexec/gnuman:$MANPATH"

# Load local binaries before anything else
export PATH="/usr/local/bin:/usr/local/sbin:$PATH"

# Use project specific binaries before global ones
# My global node binaries are managed by Yarn and located in /usr/local/bin
export PATH="node_modules/.bin:vendor/bin:$PATH" # driesvints/dotfiles/path.zsh

# Load custom binaries from `.dotfiles/bin`
export PATH="$HOME/.dotfiles/bin:$PATH"
