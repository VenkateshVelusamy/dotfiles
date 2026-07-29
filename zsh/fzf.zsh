# fzf shell integration (Ctrl-R history, Ctrl-T file insert, Alt-C cd)
if [[ -f /opt/homebrew/opt/fzf/shell/key-bindings.zsh ]]; then
  source /opt/homebrew/opt/fzf/shell/key-bindings.zsh
  source /opt/homebrew/opt/fzf/shell/completion.zsh
elif command -v fzf >/dev/null 2>&1; then
  source <(fzf --zsh) 2>/dev/null   # fzf >= 0.48 ships its own integration
fi

# Use fd for fzf's file/dir walking (respects .gitignore, includes hidden)
export FZF_DEFAULT_COMMAND='fd --type f --hidden --strip-cwd-prefix'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

export FZF_DEFAULT_OPTS='
  --height=60%
  --layout=reverse
  --border=rounded
  --preview-window=right:60%:wrap:border-left
'

# Preview file contents with bat under Ctrl-T
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=plain,numbers --line-range=:500 {}'"
