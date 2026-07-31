#!/usr/bin/env bash
# install-checkpoint-hook.sh — register the checkpoint hook in the machine-local
# ~/.claude/settings.json (which is NOT symlinked from dotfiles because it holds
# per-machine marketplace paths). Idempotent: merges the hook, backs up first,
# and points it at this dotfiles checkout's checkpoint.sh so upgrades track.
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOOK="$DOTFILES/claude/checkpoint.sh"
SETTINGS="$HOME/.claude/settings.json"

[ -f "$HOOK" ] || { echo "error: $HOOK missing"; exit 1; }
chmod +x "$HOOK"
mkdir -p "$HOME/.claude"
[ -f "$SETTINGS" ] || echo '{}' > "$SETTINGS"
cp "$SETTINGS" "$SETTINGS.bak"

HOOK="$HOOK" python3 - "$SETTINGS" <<'PY'
import json, os, sys
path = sys.argv[1]; hook = os.environ["HOOK"]
cfg = json.load(open(path))
hooks = cfg.setdefault("hooks", {})

def entry(matcher=None):
    e = {"hooks": [{"type": "command", "command": hook}]}
    if matcher is not None: e["matcher"] = matcher
    return e

def has(event, matcher):
    for e in hooks.get(event, []):
        if e.get("matcher") == matcher and \
           any(h.get("command") == hook for h in e.get("hooks", [])):
            return True
    return False

# PreCompact fires on BOTH manual (/compact) and automatic (auto) compaction.
# Compaction only — a /clear intentionally does NOT checkpoint.
for m in ("auto", "manual"):
    hooks.setdefault("PreCompact", [])
    if not has("PreCompact", m):
        hooks["PreCompact"].append(entry(m))

json.dump(cfg, open(path, "w"), indent=2)
open(path, "a").write("\n")
print("registered checkpoint hook -> PreCompact(auto,manual)")
PY

echo "done. backup at $SETTINGS.bak"
echo "AI summaries are on by default; export CLAUDE_CHECKPOINT_MODE=dump to disable model calls."
