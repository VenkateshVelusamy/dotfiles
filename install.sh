#!/usr/bin/env bash
# Symlink the dotfiles into place. Idempotent: re-running relinks.
# Existing non-symlink files are backed up to <file>.bak before linking.
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

link() {
  local src="$1" dest="$2"
  mkdir -p "$(dirname "$dest")"
  # Already the correct symlink? Nothing to do.
  if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
    echo "ok    $dest"
    return
  fi
  # Real file/dir in the way: preserve it before replacing.
  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    echo "backup $dest -> $dest.bak"
    rm -rf "$dest.bak"
    mv "$dest" "$dest.bak"
  fi
  ln -sfn "$src" "$dest"
  echo "link  $dest -> $src"
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

# Global agent instructions: one source, linked to every spot Claude and Codex
# read. Canonical config dirs plus the home-dir fallbacks both tools walk up to.
link "$DOTFILES/AGENTS.md" "$HOME/.claude/CLAUDE.md"
link "$DOTFILES/AGENTS.md" "$HOME/.codex/AGENTS.md"
link "$DOTFILES/AGENTS.md" "$HOME/AGENTS.md"
link "$DOTFILES/AGENTS.md" "$HOME/CLAUDE.md"

# Claude Code: the /checkpoint slash command (session-summary before compact/clear).
# The PreCompact/SessionEnd hook that calls claude/checkpoint.sh is NOT symlinked:
# it lives in the machine-local ~/.claude/settings.json. Enable it once with:
#   claude/install-checkpoint-hook.sh
link "$DOTFILES/claude/commands/checkpoint.md" "$HOME/.claude/commands/checkpoint.md"
# /pr-review: multi-lens PR review staged as an unpublished pending review in octo.nvim.
link "$DOTFILES/claude/commands/pr-review.md" "$HOME/.claude/commands/pr-review.md"
chmod +x "$DOTFILES/claude/checkpoint.sh" "$DOTFILES/claude/install-checkpoint-hook.sh" \
         "$DOTFILES/claude/install-obsidian.sh" "$DOTFILES/claude/pr-review.sh" 2>/dev/null || true

# claude-obsidian is a marketplace plugin (not tracked code). Reinstall it on a
# fresh machine (idempotent; vault init stays manual) with:
#   claude/install-obsidian.sh

echo
echo "Done. For machine-local secrets (e.g. work AWS env), create ~/.zshrc.local"
echo "(gitignored) and put those exports there."
