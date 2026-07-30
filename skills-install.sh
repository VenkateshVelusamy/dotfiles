#!/usr/bin/env bash
# Install the agent toolchain + skills without vendoring their content here.
# Tools install via brew/npm; skills symlink into the agent dirs so they track
# upstream instead of drifting into this repo.
set -euo pipefail

log() { printf '\033[1;34m[agent-tools]\033[0m %s\n' "$*"; }

# --- CLI tools (kunchenguid agent ecosystem) --------------------------------
# treehouse: reusable pooled git worktrees (build cache preserved per worktree)
command -v treehouse >/dev/null 2>&1 || { log "installing treehouse (brew)"; brew install treehouse; }
# gnhf: overnight agent orchestrator (bounded, committed-per-iteration loops)
command -v gnhf >/dev/null 2>&1 || { log "installing gnhf (npm)"; npm install -g gnhf; }
# tasks-axi: agent-ergonomic task/backlog CLI (firstmate's default backlog backend)
command -v tasks-axi >/dev/null 2>&1 || { log "installing tasks-axi (npm)"; npm install -g tasks-axi; }

# firstmate is a cloned agent-distro repo, not a package; clone it if absent.
# It is driven by launching a harness INSIDE it, so this only clones - never launches.
if [ ! -d "$HOME/firstmate/.git" ]; then
  log "cloning firstmate distro to ~/firstmate"
  git clone https://github.com/kunchenguid/firstmate "$HOME/firstmate"
  log "firstmate cloned. Configure per its README before launching (cd ~/firstmate && claude)."
fi

# --- Skills symlinked from their source packages ----------------------------
# gnhf ships a skill inside its npm package; link it into the agent skill dirs.
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
