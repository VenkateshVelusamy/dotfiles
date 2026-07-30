#!/usr/bin/env bash
# install-obsidian.sh — reinstall the claude-obsidian Claude Code plugin on a
# fresh machine. Idempotent: skips if already installed. Does NOT initialize a
# vault (that is a path-specific, approval-gated operation — see the note at the
# end). The plugin itself is a marketplace install, not tracked dotfiles code;
# this script only records HOW to reproduce it.
set -euo pipefail

MARKET="AgriciDaniel/claude-obsidian"
PLUGIN="claude-obsidian@agricidaniel-claude-obsidian"

command -v claude >/dev/null 2>&1 || { echo "claude CLI not found — install Claude Code first."; exit 1; }

if claude plugin list 2>/dev/null | grep -q "claude-obsidian@"; then
  echo "ok    $PLUGIN already installed"
else
  echo "add   marketplace $MARKET"
  claude plugin marketplace add "$MARKET"
  echo "install $PLUGIN"
  claude plugin install "$PLUGIN"
  echo "done  $PLUGIN installed"
fi

cat <<'NOTE'

Next (manual, per machine — not automated because it writes to a chosen vault):
  1. Initialize or adopt a vault (approval-gated preview -> apply):
       CO=~/.claude/plugins/cache/agricidaniel-claude-obsidian/claude-obsidian/*/scripts/claude-obsidian.py
       python3 $CO init "$HOME/Documents/Notes" \
         --generated-at "$(date -u +%Y-%m-%dT%H:%M:%SZ)" --operation-id init-reviewed
       # review the JSON plan, then repeat with --approved-plan-sha256 <sha> --apply
     (use `adopt` instead of `init` for an existing Obsidian vault)
  2. Use it: /claude-obsidian:wiki , /claude-obsidian:wiki-ingest , /claude-obsidian:wiki-query
NOTE
