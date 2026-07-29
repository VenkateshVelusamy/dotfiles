#!/usr/bin/env bash
# Symlink the dotfiles into place. Idempotent: re-running relinks.
# Existing non-symlink files are backed up to <file>.bak before linking.
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

link() {
  local src="$1" dest="$2"
  mkdir -p "$(dirname "$dest")"
  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    echo "backing up $dest -> $dest.bak"
    mv "$dest" "$dest.bak"
  fi
  ln -sfn "$src" "$dest"
  echo "linked $dest"
}

link "$DOTFILES/tmux/tmux.conf"        "$HOME/.tmux.conf"
link "$DOTFILES/wezterm/wezterm.lua"   "$HOME/.wezterm.lua"
link "$DOTFILES/starship/starship.toml" "$HOME/.config/starship.toml"
link "$DOTFILES/nvim/init.lua"         "$HOME/.config/nvim/init.lua"

link "$DOTFILES/zsh/zshrc"             "$HOME/.zshrc"
link "$DOTFILES/zsh/zshenv"            "$HOME/.zshenv"
link "$DOTFILES/zsh/zprofile"          "$HOME/.zprofile"
for f in "$DOTFILES"/zsh/*.zsh; do
  link "$f" "$HOME/.config/zsh/$(basename "$f")"
done

link "$DOTFILES/cheatsheets/nvim-cheatsheet.md"    "$HOME/.nvim-cheatsheet.md"
link "$DOTFILES/cheatsheets/tmux-cheatsheet.md"    "$HOME/.tmux-cheatsheet.md"
link "$DOTFILES/cheatsheets/wezterm-cheatsheet.md" "$HOME/.wezterm-cheatsheet.md"
link "$DOTFILES/cheatsheets/zsh-cheatsheet.md"     "$HOME/.zsh-cheatsheet.md"

echo
echo "Done. For machine-local secrets (e.g. work AWS env), create ~/.zshrc.local"
echo "(gitignored) and put those exports there."
