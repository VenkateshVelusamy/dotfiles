# claude — Claude Code customizations

Generic Claude Code additions, tracked here and installed via the repo's
`install.sh` (+ a one-time hook registration).

## /checkpoint — session summary before compact/clear

Writes a resume-checkpoint of a session so it survives Claude Code's context
compaction or a `/clear`. Two entry points, one shared idea:

| Piece | Fires | Uses | Quality |
|---|---|---|---|
| `commands/checkpoint.md` (slash command) | manually: you type `/checkpoint` | the **live session's** own reasoning | highest — full context |
| `checkpoint.sh` (hook) | automatically: PreCompact (auto + manual) and SessionEnd (clear/logout/exit) | reads `transcript_path`, shells out to headless `claude -p` | good — re-read transcript |

Output lands in `$CLAUDE_CHECKPOINT_DIR` (default `~/.claude/checkpoints/`),
named `<timestamp>-<project>-<trigger>.md`.

### Why both

A hook is a blind shell command — it can't reason, so for a real summary it
shells out to a separate `claude -p` call. The slash command runs in the live
session, so its summary is richer. Use `/checkpoint` when you know you're about
to compact; the hook is the automatic safety net.

### Modes

`CLAUDE_CHECKPOINT_MODE` controls the hook:

- `ai` (default) — headless `claude -p` produces a structured summary. Costs
  tokens and adds ~30–60s before compaction.
- `dump` — no model call; deterministically extracts the user/assistant
  transcript tail. Free and instant. Set `export CLAUDE_CHECKPOINT_MODE=dump`.

A recursion guard (`CLAUDE_CHECKPOINT_ACTIVE`) stops the headless `claude -p`
session's own SessionEnd from re-triggering the hook.

## Install

`install.sh` symlinks the slash command:

```
claude/commands/checkpoint.md -> ~/.claude/commands/checkpoint.md
```

The hook is **not** symlinked — it lives in the machine-local
`~/.claude/settings.json` (which holds per-machine marketplace paths and is not
tracked). Register it once per machine:

```sh
claude/install-checkpoint-hook.sh   # idempotent; backs up settings.json first
```

That adds `PreCompact` (matchers `auto` + `manual`) and `SessionEnd` hooks
pointing at this checkout's `checkpoint.sh`, so product upgrades track the repo.

## Caveats

- A hook writes a **side file**; it does not change what the compactor keeps in
  context. "Checkpoint" = durable external record to re-read next session.
- `SessionEnd` cannot block exit — keep it quick. Use `dump` mode if the `ai`
  delay on `/clear` bothers you.
- Requires `claude` on PATH for `ai` mode; falls back to a dump otherwise.

## claude-obsidian plugin

`claude-obsidian` (a local-first Obsidian knowledge-vault plugin) is installed
from a Claude Code marketplace, not vendored here — the code lives in
`~/.claude/plugins/` and its enablement in the machine-local
`~/.claude/settings.json`. To reproduce it on a fresh machine, run the
idempotent installer:

```sh
claude/install-obsidian.sh   # adds the marketplace + installs the plugin
```

Vault initialization is deliberately **not** automated — it writes to a chosen
directory behind an approval-gated preview. The script prints the exact
`init`/`adopt` commands to run once per machine. Day-to-day use:
`/claude-obsidian:wiki-ingest`, `/claude-obsidian:wiki-query`.
