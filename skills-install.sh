#!/usr/bin/env bash
# Install agent skills without vendoring their content into this repo.
# Skills are installed via their own tooling / npm packages and symlinked into
# the agent skill dirs, so they update with the source instead of drifting here.
set -euo pipefail

log() { printf '\033[1;34m[skills]\033[0m %s\n' "$*"; }

# --- gnhf: overnight agent orchestrator; ships a skill inside its npm package -
command -v gnhf >/dev/null 2>&1 || { log "installing gnhf (npm)"; npm install -g gnhf; }

GNHF_SKILL="$(npm root -g)/gnhf/skills/gnhf"
if [ -d "$GNHF_SKILL" ]; then
  for dir in "$HOME/.claude/skills" "$HOME/.codex/skills"; do
    mkdir -p "$dir"
    ln -sfn "$GNHF_SKILL" "$dir/gnhf"
    log "linked gnhf skill -> $dir/gnhf"
  done
else
  log "WARN: gnhf skill dir not found at $GNHF_SKILL"
fi

log "done. Restart your agent session to pick up new skills."
