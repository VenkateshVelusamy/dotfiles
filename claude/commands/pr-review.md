---
description: Review a PR with multiple lenses and stage findings as an unpublished pending review in octo.nvim for curation before submit
---

Review pull request **$ARGUMENTS** and stage the findings as an unpublished
pending review that shows up in octo.nvim for the captain to curate before
submitting. Nothing is ever published autonomously.

Run from inside the repo's local clone (the one whose git remote points at the
PR's host). Steps:

0. **Create a throwaway review worktree (isolation).** So the captain's working
   changes are never disturbed, do the octo review in a detached worktree that
   shares the clone's remotes. From the captain's clone `<clone>`:
   `git -C <clone> worktree add /tmp/pr-review-<N> --detach`
   octo reads the diff from the server, so a detached checkout is enough - the
   PR branch does NOT need to be checked out. Everything below (gh, octo) runs
   from `/tmp/pr-review-<N>`. Never use `:Octo pr checkout` - it would switch a
   branch and defeat the isolation.

1. **Fetch the current head.** The PR may have moved since it was opened. Get
   the live diff against its base for the current head SHA - never review a
   stale snapshot:
   `GH_HOST=<host> gh pr diff <N>` (or the API diff). Note the head SHA.

2. **Read the whole diff.** Understand what each file/hunk changes and how the
   pieces fit before forming findings. Do not skim.

3. **Apply the review lenses** to the diff:
   - correctness / bugs (logic, edge cases, error handling)
   - security (auth, secrets, input at trust boundaries, over-broad IAM/permissions)
   - simplification / YAGNI (unrequested abstraction, dead code, redundant deps)
   For a large diff, dispatch the lenses as parallel subagents so each gets its
   own context, then vet every finding yourself before it reaches the captain.

4. **Show every finding to the captain in chat first (gate 1).** For each:
   file, line, the concern, and a suggested fix. The captain cuts, edits, or
   approves before anything touches the PR server.

5. **Stage the approved findings.** Write them to a temp JSON file as
   `[ { "path", "line", "body", "side": "RIGHT" }, ... ]` (line = the line
   number in the file's NEW version; use side "LEFT" only for a removed line),
   then run:
   `~/dotfiles/claude/pr-review.sh <N> /tmp/pr-<N>-findings.json`
   The script re-fetches the head SHA, refuses a stale anchor, and posts the
   comments as a PENDING review (no publish).

6. **Hand off to octo (gate 2).** Tell the captain to open the review worktree
   in nvim (`nvim /tmp/pr-review-<N>`) and run `:Octo pr edit <N>` then
   `:Octo review resume` - the findings appear as inline threads. They curate
   (edit / `SPC cd` delete / `SPC ca` add) and submit with `SPC vs`, or discard
   everything with `SPC vd` / `SPC oR`.

7. **Tear down after the captain is done** (only on their say-so):
   `git -C <clone> worktree remove /tmp/pr-review-<N>`
   This refuses if the worktree has uncommitted changes - do NOT force it;
   investigate instead. The captain's main clone is never touched.

Re-running on the same PR: discard the old pending review first (`SPC vd` in
octo, or the captain runs `:Octo review discard`) so comments don't duplicate.

Prefix each finding body with its lens, e.g. `[security]`, `[correctness]`,
`[simplify]`, so machine findings are distinguishable from human comments.
