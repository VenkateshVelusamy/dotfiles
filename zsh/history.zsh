# History
HISTFILE="$HOME/.local/state/zsh/history"
HISTSIZE=100000
SAVEHIST=100000

setopt APPEND_HISTORY
setopt SHARE_HISTORY          # new commands land in history for all open shells
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE      # a leading space keeps a command out of history
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FIND_NO_DUPS

# Shell behaviour
setopt AUTOCD                 # type a directory name to cd into it
setopt NOBEEP
setopt NUMERIC_GLOB_SORT      # file9 before file10

# Completion
autoload -Uz compinit
compinit -d "$HOME/.cache/zsh/zcompdump"
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'   # case-insensitive
