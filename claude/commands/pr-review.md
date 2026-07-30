---
description: Review a PR with multiple lenses and stage findings as an unpublished pending review in octo.nvim for curation before submit
---

Review pull request **$ARGUMENTS** and stage the findings as an unpublished
pending review that shows up in octo.nvim for the captain to curate before
submitting. Nothing is ever published autonomously.

Run from inside the repo's local clone (the one whose git remote points at the
PR's host). Steps:

0. **Isolation via treehouse (a pooled-worktree tool).** The captain's working
   changes are never touched: all review work happens in a treehouse worktree,
   which shares the clone's remotes (so octo resolves the PR). Do NOT hand-roll
   `git worktree`. Reading the diff (steps 1-4) can run from the clone or a
   brief lease; the interactive octo session (step 6) is where treehouse's
   auto-return matters. octo reads the diff from the server, so the PR branch is
   never checked out - never use `:Octo pr checkout`.

1. **Fetch the current head.** The PR may have moved since it was opened. Get
   the live diff against its base for the current head SHA - never review a
   stale snapshot:
   `GH_HOST=<host> gh pr diff <N>` (or the API diff). Note the head SHA.

2. **Read the whole diff.** Understand what each file/hunk changes and how the
   pieces fit before forming findings. Do not skim.

3. **Dispatch one subagent per review lens, in parallel.** Send all three in a
   single message so they run concurrently, each with its own fresh context:
   - a subagent running the **`/review-code`** skill (correctness, bugs, error
     handling, tests)
   - a subagent running the **`/security-review`** skill (auth, secrets,
     trust-boundary input, over-broad IAM/permissions)
   - a subagent running the **`/ponytail:ponytail-review`** skill (unrequested
     abstraction, dead code, redundant deps, simpler equivalents)
   Give each subagent the PR number, the review worktree path, and the exact
   head SHA, and require it to return findings as a list of
   `{ path, line, side, body }` with `line` in the NEW file version. The
   subagents only read and report - they never post to the PR or write vault
   state.

4. **Consolidate, then show the captain (gate 1).** Merge the three subagents'
   findings into one list: drop duplicates where two lenses flag the same
   line, keep the strongest wording, and prefix each body with its lens
   (`[correctness]` / `[security]` / `[simplify]`). Vet every finding yourself
   against the diff before showing it - discard anything you cannot confirm
   against the actual code. Then present the consolidated set to the captain
   (file, line, concern, suggested fix). The captain cuts, edits, or approves
   before anything touches the PR server.

5. **Stage the approved findings.** Write them to a temp JSON file as
   `[ { "path", "line", "body", "side": "RIGHT" }, ... ]` (line = the line
   number in the file's NEW version; use side "LEFT" only for a removed line),
   then run the script FROM INSIDE the worktree (it resolves the remote from
   the cwd), wrapped in a subshell so it never moves the parent shell:
   `(cd /tmp/pr-review-<N> && ~/dotfiles/claude/pr-review.sh <N> /tmp/pr-<N>-findings.json)`
   The script re-fetches the current head SHA at post time, deletes any
   existing pending review first (GitHub allows only one per user per PR, so
   this prevents a 422 and stops duplicate comments), and posts the batch as a
   PENDING review with no publish. Resolve each finding's line against the file
   at the CURRENT head just before writing the JSON - subagents often return
   diff-file offsets, not file line numbers; verify every anchor yourself.

6. **Open the review in tmux + nvim + octo (gate 2).** If inside tmux, launch a
   dedicated window that boots a pooled treehouse worktree straight into octo:
   `tmux new-window -n pr-<N>-review "~/dotfiles/claude/pr-review-open.sh <N> --host <host> --clone <clone>"`
   That helper runs `treehouse get` (acquires a pooled worktree) with a shell
   that execs `nvim -c 'Octo pr edit <N>' -c 'Octo review resume'`, so the
   findings appear as inline threads on open. (Outside tmux, tell the captain to
   run the helper themselves.) The captain curates (edit / `SPC cd` delete /
   `SPC ca` add) and publishes with `SPC vs` -> `<C-r>` request-changes /
   `<C-m>` comment, or discards with `SPC vd` / `SPC oR`. Nothing reaches the
   author until that submit.

7. **Teardown is automatic - no step needed.** When the captain quits nvim
   (`:qa`) or closes the tmux window, the treehouse subshell exits and treehouse
   AUTOMATICALLY returns the worktree to its pool (it is reused, not destroyed).
   Only for a genuinely stuck session (lingering processes) use
   `treehouse return --force <path>`; never `destroy` unless the captain asks.

Re-running on the same PR is safe: the script clears any existing pending
review before staging, so comments never duplicate. (A pending review the
captain is mid-curation in octo will also be cleared - re-run only when they
are done with the prior batch.)

Prefix each finding body with its lens, e.g. `[security]`, `[correctness]`,
`[simplify]`, so machine findings are distinguishable from human comments.
