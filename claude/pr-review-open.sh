#!/usr/bin/env bash
# pr-review-open.sh - open a PR review in a pooled treehouse worktree, in nvim+octo.
#
# Designed to be the tmux window command. It runs `treehouse get`, which acquires a
# pooled worktree and opens a subshell in it; we point that subshell's $SHELL at an
# inline exec of nvim launched straight into octo. When you quit nvim the subshell
# exits, and treehouse AUTOMATICALLY returns the worktree to the pool - so closing the
# window is the teardown. No explicit cleanup step.
#
# Usage (from inside the repo clone, or pass --clone):
#   pr-review-open.sh <pr-number> [--host <gh-host>] [--clone <path>]
#
# The clone must have a remote (ghe/origin) pointing at the PR's host so octo resolves.
set -euo pipefail

pr=${1:?usage: pr-review-open.sh <pr-number> [--host <host>] [--clone <path>]}
shift
host=siemens.ghe.com
clone=$PWD
while [ $# -gt 0 ]; do
  case "$1" in
    --host) host=${2:?}; shift 2 ;;
    --clone) clone=${2:?}; shift 2 ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
done

command -v treehouse >/dev/null || { echo "treehouse not found (brew install treehouse)"; exit 1; }
command -v nvim >/dev/null || { echo "nvim not found"; exit 1; }

# Transient $SHELL for the treehouse subshell: exec nvim into octo, so quitting nvim
# exits the shell and triggers treehouse's auto-return. mktemp keeps it self-contained.
runner=$(mktemp "${TMPDIR:-/tmp}/pr-review-runner.XXXXXX.sh")
trap 'rm -f "$runner"' EXIT
cat >"$runner" <<RUNNER
#!/usr/bin/env bash
exec env GH_HOST=$host nvim -c "Octo pr edit $pr" -c "Octo review resume"
RUNNER
chmod +x "$runner"

# treehouse get runs in the clone, hands out a pooled worktree, runs our runner as its
# shell, and auto-returns the worktree when nvim exits.
cd "$clone"
SHELL="$runner" treehouse get
