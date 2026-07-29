# Plugins — cloned into ~/.config/zsh/plugins on first launch, no framework
ZPLUGINDIR="$HOME/.config/zsh/plugins"

_zplugin_load() {
  local plugin_path="${ZPLUGINDIR}/${2}"
  if [[ ! -d "$plugin_path" ]]; then
    mkdir -p "$ZPLUGINDIR"
    echo "Installing ${2}..."
    git clone --depth=1 "https://github.com/${1}/${2}" "$plugin_path" \
      || { echo "ERROR: failed to install ${2}" >&2; return 1; }
  fi
  source "${plugin_path}/${2}.plugin.zsh"
}

zplugin-update() {
  local dir
  for dir in "${ZPLUGINDIR}"/*/; do
    echo "Updating ${dir:t}..."
    git -C "$dir" pull --ff-only
  done
}

# Vi cursor shapes per mode
ZVM_INSERT_MODE_CURSOR=$ZVM_CURSOR_BEAM
ZVM_NORMAL_MODE_CURSOR=$ZVM_CURSOR_BLOCK
ZVM_VISUAL_MODE_CURSOR=$ZVM_CURSOR_BLOCK

_zplugin_load zsh-users zsh-autosuggestions
_zplugin_load zsh-users zsh-history-substring-search
_zplugin_load jeffreytse zsh-vi-mode
_zplugin_load zdharma-continuum fast-syntax-highlighting

# zsh-vi-mode wipes all keybindings on init, so anything we need (fzf widgets,
# history arrows, word motions) must be re-registered in this hook to survive.
zvm_after_init() {
  # Up/Down filter history by the prefix typed. Bind in viins explicitly: the
  # arrow sequence starts with ESC, which vi-mode owns, so the default keymap
  # bind gets shadowed.
  bindkey -M viins '^[[A' history-substring-search-up
  bindkey -M viins '^[[B' history-substring-search-down
  # In normal mode, k/j do the same (vim-idiomatic history scroll)
  bindkey -M vicmd 'k' history-substring-search-up
  bindkey -M vicmd 'j' history-substring-search-down
  # Ctrl-Left / Ctrl-Right: word motions
  bindkey -M viins '^[[1;5C' forward-word
  bindkey -M viins '^[[1;5D' backward-word
  # Re-apply fzf widgets (zvm clobbered them)
  bindkey '^R' fzf-history-widget
  bindkey '^T' fzf-file-widget
}
