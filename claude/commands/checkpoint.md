---
description: Summarize the current session to a checkpoint file so it can resume cold after compact/clear
---

Write a checkpoint of our current session to
`~/.claude/checkpoints/<timestamp>-<project>-manual.md` (create the directory if
needed; timestamp format `YYYYMMDD-HHMMSS`).

Use everything in your current context — not a re-read transcript — and write
these sections:

- **## Goal** — what we're actually trying to accomplish.
- **## Decisions made** — choices locked in, with the reasoning.
- **## Files/systems changed** — exact paths and what changed.
- **## Open threads / next steps** — the precise next actions, enough that a
  fresh session can resume with zero re-discovery.
- **## Gotchas** — anything surprising, any dead-ends already ruled out.

Be specific: real paths, command names, account/profile names, URLs. No fluff —
this is read cold by a future session. After writing, confirm the file path.

$ARGUMENTS
