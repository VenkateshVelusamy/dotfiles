#!/usr/bin/env bash
# pr-review-open.sh - open a PR review in a pooled treehouse worktree, in nvim+octo.
#
# Designed to be the tmux window command. It LEASES a pooled worktree (durable, prints
# only the path), runs nvim directly in it opened on the PR, and returns the lease when
# nvim exits - so closing the window is the teardown, no explicit cleanup step.
#
# It deliberately does NOT use the `treehouse get` subshell + $SHELL trick: treehouse
# exports $SHELL to the child, so pointing $SHELL at an nvim-exec wrapper makes nvim
# (and octo's gh subprocesses, which spawn via $SHELL) re-exec nvim recursively - a
# fork bomb. Leasing + running nvim directly avoids that entirely.
#
# Usage (from inside the repo clone, or pass --clone):
#   pr-review-open.sh <pr-number> [--host <gh-host>] [--clone <path>] [--map <file>]
#
# --map opens a review mental-map file in a left split alongside the octo PR buffer.
# The clone must have a remote (ghe/origin) pointing at the PR's host so octo resolves.
set -euo pipefail

pr=${1:?usage: pr-review-open.sh <pr-number> [--host <host>] [--clone <path>] [--map <file>]}
shift
host=siemens.ghe.com
clone=$PWD
map=
while [ $# -gt 0 ]; do
  case "$1" in
    --host) host=${2:?}; shift 2 ;;
    --clone) clone=${2:?}; shift 2 ;;
    --map) map=${2:?}; shift 2 ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
done

command -v treehouse >/dev/null || { echo "treehouse not found (brew install treehouse)"; exit 1; }
command -v nvim >/dev/null || { echo "nvim not found"; exit 1; }

cd "$clone"
worktree=$(treehouse get --lease --lease-holder "pr-review-$pr")
[ -n "$worktree" ] && [ -d "$worktree" ] || { echo "treehouse did not return a worktree path"; exit 1; }

# Return the lease no matter how nvim exits (quit, crash, window close/kill).
trap 'treehouse return --force "$worktree" >/dev/null 2>&1 || true' EXIT INT TERM

# Open the PR buffer; if a map file was given, open it in a left vertical split so the
# mental map and the octo PR sit side by side. Do NOT chain `Octo review resume` here -
# it races octo's async gh fetch; run `:Octo review resume` (or SPC vr) once nvim is up.
cd "$worktree"
if [ -n "$map" ] && [ -f "$map" ]; then
  GH_HOST="$host" nvim -c "Octo pr edit $pr" -c "vsplit $map" -c "wincmd h"
else
  GH_HOST="$host" nvim -c "Octo pr edit $pr"
fi
