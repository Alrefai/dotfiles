source ~/.fzf.zsh

# Start in a tmux split pane
export FZF_TMUX=1

# Use `tree` command to show the entries of the directory
export FZF_ALT_C_OPTS="--preview 'tree -C {} | head -200'"

# Run fzf in full screen mode with more options
export FZF_DEFAULT_OPTS='--bind J:down,K:up --reverse --ansi --multi --no-height --no-reverse --select-1 --exit-0'

# Full command on preview window
export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window down:3:hidden:wrap --bind '?:toggle-preview'"

# Use 'bfs` to browse folders
export FZF_ALT_C_COMMAND="bfs -type d"

# Preview the content of the file under the cursor
# Using highlight (http://www.andre-simon.de/doku/highlight/en/highlight.html)
export FZF_CTRL_T_OPTS="--preview '(highlight -O ansi -l {} 2> /dev/null || cat {} || tree -C {}) 2> /dev/null | head -200'"

# ---- bag-man/dotfiles/bashrc ------------------------------------------------
export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow -g "!{.git,node_modules,*.swp,dist,*.coffee}/*" 2> /dev/null'

export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# export FZF_ALT_C_COMMAND="cd ~/; bfs -type d -nohidden | sed s/^\./\~/"
# export FZF_DEFAULT_OPTS='--bind J:down,K:up --reverse --ansi --multi'
# -----------------------------------------------------------------------------
