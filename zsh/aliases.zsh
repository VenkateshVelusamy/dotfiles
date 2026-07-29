# Modern ls (eza)
alias ls='eza --icons=auto'
alias ll='eza -lh --icons=auto --git'
alias la='eza -lah --icons=auto --git'
alias tree='eza --tree --icons=auto'
compdef eza=ls 2>/dev/null

# Better cat / grep
alias cat='bat'
alias grep='rg --color=auto'
alias diff='diff --color=auto'
alias df='df -h'

# Navigation
alias -- -='cd -'             # cd to previous directory

# Editor
alias vim='nvim'

# Cheat sheets.
#   cheat              fuzzy-search every line across ALL sheets (fzf)
#   cheat zsh|tmux|nvim|wezterm   open one sheet in the pager
cheat() {
  local topic="$1"
  # No arg: fuzzy search across all sheets. Each line is tagged with its tool.
  if [[ -z "$topic" ]]; then
    if ! command -v fzf >/dev/null 2>&1; then
      echo "usage: cheat {zsh|tmux|nvim|wezterm}  (install fzf for fuzzy search)"
      return 1
    fi
    local t
    for t in zsh tmux nvim wezterm; do
      local f="$HOME/.${t}-cheatsheet.md"
      [[ -r "$f" ]] && awk -v tag="$t" '{printf "%-8s %s\n", "["tag"]", $0}' "$f"
    done | fzf --prompt="cheat> " --height=80% --layout=reverse --border=rounded \
               --info=inline --header="fuzzy search all cheat sheets (Enter to close)"
    return 0
  fi
  local file="$HOME/.${topic}-cheatsheet.md"
  if [[ ! -r "$file" ]]; then
    echo "no cheat sheet for '$topic' ($file)"
    return 1
  fi
  if command -v bat >/dev/null 2>&1; then
    bat --style=plain --paging=always -l markdown "$file"
  else
    ${PAGER:-less} "$file"
  fi
}
# Tab-complete the topic names
_cheat() { compadd zsh tmux nvim wezterm }
compdef _cheat cheat 2>/dev/null

# Git
alias glog='PAGER="less -F -X" git log'
alias gadog='PAGER="less -F -X" git log --all --decorate --oneline --graph'
