#!/usr/bin/env bash
# pr-review.sh - stage AI review findings as an UNPUBLISHED pending review on a PR,
# so they show up in octo.nvim (:Octo review resume) for you to curate before submit.
#
# Generic: resolves host + owner/repo from the current clone's git remote (prefers a
# "ghe" remote, then "origin"), so it works for github.com or any GitHub Enterprise.
# Nothing is published - the review is created in PENDING state (no "event"), visible
# only to you until you submit it yourself in octo.
#
# Usage:
#   pr-review.sh <pr-number> <findings.json>
#   pr-review.sh <pr-number> -           # read findings JSON from stdin
#
# findings.json: [ { "path": "file", "line": 42, "body": "text", "side": "RIGHT" }, ... ]
#   side defaults to RIGHT (the new version). Use LEFT to comment on a removed line.
#
# Self-check:  pr-review.sh --selfcheck
set -euo pipefail

resolve_remote() {
  # Echo "<host> <owner/repo>" from the preferred remote, mirroring octo's default_remote.
  local url="" name
  for name in ghe origin; do
    url=$(git config --get "remote.${name}.url" 2>/dev/null) && [ -n "$url" ] && break
  done
  [ -n "$url" ] || { echo "no ghe/origin remote in $(pwd)" >&2; return 1; }
  # Strip scheme and .git, split host from path. Handles https:// and git@host:owner/repo.
  local hostpath=${url#*://}
  hostpath=${hostpath#*@}
  hostpath=${hostpath%.git}
  local host=${hostpath%%[:/]*}
  local repo=${hostpath#*[:/]}
  case "$host" in
    ""|/*|.*) echo "remote '$url' is not a GitHub host (local path?)" >&2; return 1 ;;
  esac
  echo "$host $repo"
}

selfcheck() {
  # Verify remote parsing without touching the network.
  local out
  out=$(cd "$(mktemp -d)" && git init -q . && \
        git remote add origin https://siemens.ghe.com/foundation/khazad-substrate-infrastructure.git && \
        url=$(git config --get remote.origin.url); \
        hostpath=${url#*://}; hostpath=${hostpath#*@}; hostpath=${hostpath%.git}; \
        echo "${hostpath%%[:/]*} ${hostpath#*[:/]}")
  [ "$out" = "siemens.ghe.com foundation/khazad-substrate-infrastructure" ] \
    || { echo "selfcheck FAILED: got '$out'" >&2; return 1; }
  echo "selfcheck ok"
}

[ "${1:-}" = "--selfcheck" ] && { selfcheck; exit $?; }

pr=${1:?usage: pr-review.sh <pr-number> <findings.json|->}
findings_arg=${2:?usage: pr-review.sh <pr-number> <findings.json|->}

read -r host repo < <(resolve_remote)
export GH_HOST="$host"

# Fetch the CURRENT head SHA - refuse to anchor against a stale commit.
head_sha=$(gh api "repos/$repo/pulls/$pr" --jq '.head.sha')
[ -n "$head_sha" ] || { echo "could not resolve head SHA for PR #$pr on $host/$repo" >&2; exit 1; }

# Load findings, inject default side, and validate shape.
findings=$(cat "$findings_arg")
comments=$(jq -c '[ .[] | { path, line, side: (.side // "RIGHT"), body } ]' <<<"$findings") \
  || { echo "findings JSON is malformed" >&2; exit 1; }
count=$(jq 'length' <<<"$comments")
[ "$count" -gt 0 ] || { echo "no findings to stage" >&2; exit 1; }

echo "Staging $count pending comment(s) on $host/$repo PR #$pr @ ${head_sha:0:12} (unpublished)..."

# GitHub allows only one pending review per user per PR. Clear any existing one
# (a prior run, or a stray octo draft) so re-running never fails with 422 or stacks
# duplicate comments. Only PENDING reviews are deleted; submitted reviews are untouched.
existing=$(gh api "repos/$repo/pulls/$pr/reviews" --jq ".[] | select(.state==\"PENDING\") | .id")
for rid in $existing; do
  echo "  clearing existing pending review $rid"
  gh api --method DELETE "repos/$repo/pulls/$pr/reviews/$rid" >/dev/null
done

# Create the review with NO "event" field -> stays PENDING, invisible until you submit.
jq -n --arg sha "$head_sha" --argjson comments "$comments" \
  '{ commit_id: $sha, comments: $comments }' \
| gh api --method POST "repos/$repo/pulls/$pr/reviews" --input - --jq '.id' >/dev/null

echo "Done. In nvim (inside this clone):  :Octo pr edit $pr   then  :Octo review resume"
echo "Curate the threads, then submit with SPC vs (or discard with SPC vd)."
