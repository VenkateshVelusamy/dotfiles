#!/usr/bin/env bash
# checkpoint.sh — write a session checkpoint from a Claude Code hook.
#
# Wired as a PreCompact hook (auto + manual). Compaction only — a /clear does
# not checkpoint. Reads the hook JSON on stdin, extracts transcript_path, and
# produces a checkpoint markdown file so a session survives compaction.
#
# Summary quality is controlled by CLAUDE_CHECKPOINT_MODE:
#   ai    (default) — shell out to headless `claude -p` for a real summary
#   dump            — no model call; extract user/assistant text deterministically
# Set CLAUDE_CHECKPOINT_MODE=dump to avoid token cost.
#
# Output dir: $CLAUDE_CHECKPOINT_DIR (default ~/Documents/Notes/inbox), so the
# checkpoint lands in the Obsidian vault inbox and can be filed with
# /claude-obsidian:wiki-ingest. Generic: no project-specific assumptions.
set -euo pipefail

MODE="${CLAUDE_CHECKPOINT_MODE:-ai}"
OUTDIR="${CLAUDE_CHECKPOINT_DIR:-$HOME/Documents/Notes/inbox}"

# Recursion guard: the AI path spawns `claude -p`, whose own compaction would
# re-fire this hook. Bail out when we're already inside a checkpoint's session.
if [ -n "${CLAUDE_CHECKPOINT_ACTIVE:-}" ]; then
  echo '{"systemMessage":"checkpoint: nested session, skipped"}'; exit 0
fi

input="$(cat)"

read -r transcript trigger reason cwd session <<EOF
$(printf '%s' "$input" | python3 -c '
import json,sys
try: d=json.load(sys.stdin)
except Exception: d={}
print(
  d.get("transcript_path",""),
  d.get("trigger","na"),
  d.get("reason","na"),
  d.get("cwd",""),
  (d.get("session_id","") or "")[:8],
)
')
EOF

# Nothing to summarize without a transcript.
[ -n "$transcript" ] && [ -f "$transcript" ] || { echo '{"systemMessage":"checkpoint: no transcript, skipped"}'; exit 0; }

mkdir -p "$OUTDIR"
ts="$(date +%Y%m%d-%H%M%S)"
label="${trigger}"; [ "$label" = "na" ] && label="${reason}"
proj="$(basename "${cwd:-session}")"
out="$OUTDIR/${ts}-${proj}-${label}.md"

# Deterministic transcript digest (used as dump body and as AI input).
digest="$(python3 - "$transcript" <<'PY'
import json,sys
def text(msg):
    c=msg.get("content")
    if isinstance(c,str): return c
    if isinstance(c,list):
        out=[]
        for b in c:
            if isinstance(b,dict):
                bt=b.get("type")
                if bt=="text": out.append(b.get("text",""))
                elif bt=="tool_use":
                    # keep the command or query itself (a key artifact)
                    inp=b.get("input",{}) or {}
                    arg=inp.get("command") or inp.get("query") or inp.get("file_path") \
                        or inp.get("prompt") or inp.get("pattern") or ""
                    if isinstance(arg,str) and arg:
                        arg=" ".join(arg.split())
                        if len(arg)>400: arg=arg[:400]+" …"
                        out.append(f"[{b.get('name','tool')}: {arg}]")
                    else:
                        out.append(f"[{b.get('name','tool')}]")
        return " ".join(out)
    return ""
lines=[]
for line in open(sys.argv[1]):
    try: d=json.loads(line)
    except Exception: continue
    if d.get("type") not in ("user","assistant"): continue
    m=d.get("message")
    if not isinstance(m,dict): continue
    role=m.get("role","?"); t=text(m).strip()
    if not t: continue
    t=" ".join(t.split())
    if len(t)>4000: t=t[:4000]+" …"
    lines.append(f"{role.upper()}: {t}")
# Keep a generous window so the summary is truthful, not just the tail.
# ~1200 turns with richer excerpts; the model does the condensing, not us.
print("\n".join(lines[-1200:]))
PY
)"

# Obsidian frontmatter so the note is filable/searchable in the vault.
iso="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
frontmatter() {
  printf -- '---\n'
  printf 'type: session-checkpoint\n'
  printf 'created: %s\n' "$iso"
  printf 'project: "%s"\n' "${cwd:-unknown}"
  printf 'trigger: %s\n' "$label"
  printf 'session: %s\n' "${session}"
  printf 'tags: [checkpoint, claude-code]\n'
  printf -- '---\n\n'
}

write_dump() {
  { frontmatter
    echo "# Session checkpoint — $ts (${proj})"
    echo
    echo "> Deterministic transcript excerpt (no model summary)."
    echo
    echo "## Transcript"
    echo
    printf '%s\n' "$digest"
  } > "$out"
}

if [ "$MODE" = "ai" ] && command -v claude >/dev/null 2>&1; then
  prompt='You are writing a TRUTHFUL, COMPREHENSIVE session checkpoint from the Claude Code transcript below. It is read cold by a future session, so completeness beats brevity — capture everything load-bearing, but do not invent anything not supported by the transcript. Output ONLY Markdown: no preamble, no conversational address, no outer code fence. Start directly at the ## Goal heading. Use these sections; omit a section only if it is genuinely empty:

## Goal
What we set out to accomplish (and how it evolved during the session).

## Key commands & queries
The important shell commands, searches, API/MCP calls, and their essential results. Preserve exact commands, paths, flags, IDs, URLs.

## Findings
What we learned/discovered — facts established, root causes, how things actually work.

## Researched
What we investigated and where we looked (repos, docs, tools), even if inconclusive.

## Decisions — locked
Choices committed to, each with the one-line reason.

## Decisions — rejected / ruled out
Options considered and dropped, and WHY (so we do not revisit dead-ends).

## Changed
Files/systems created or modified — exact paths and what changed.

## Learnings & gotchas
Non-obvious things, surprises, constraints, pitfalls to remember.

## Where we ended
The exact current state at checkpoint time.

## Next
Precise next actions to resume with zero re-discovery.

Be specific throughout: real paths, command names, account/profile names, URLs, error text. Group related points; use sub-bullets where helpful. Do not pad, but do not drop anything important.'
  body="$(printf '%s' "$digest" | CLAUDE_CHECKPOINT_ACTIVE=1 claude -p "$prompt" 2>/dev/null || true)"
  if [ "$(printf '%s' "$body" | wc -w | tr -d ' ')" -ge 30 ]; then
    { frontmatter
      printf '%s\n' "$body"
      echo; echo "---"; echo "_checkpoint ${label} · session ${session} · ${ts}_"
    } > "$out"
  else
    write_dump   # model call failed/thin — never lose the checkpoint
  fi
else
  write_dump
fi

echo "{\"systemMessage\":\"checkpoint saved: $out\"}"
