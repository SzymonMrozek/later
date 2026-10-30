#!/usr/bin/env bash
# Lints and tests the parts of the monorepo this branch changes. The Worktrunk pre-merge hook
# runs it before anything lands on main; run it yourself with `mise run check`.
set -euo pipefail
cd "$(dirname "$0")/.."

target="main"
while [ "$#" -gt 0 ]; do
  case "$1" in
    --target) target="$2"; shift 2 ;;
    *) echo "error: unknown argument: $1" >&2; exit 2 ;;
  esac
done

changed="$(
  git diff --name-only "$(git merge-base "$target" HEAD)" HEAD
  git diff --name-only HEAD
  git ls-files --others --exclude-standard
)"

touches() { grep -qE "$1" <<<"$changed"; }
shared='^(mise\.toml|compose\.yaml|scripts/|\.config/|\.github/)'

ran=false
if touches '^server/' || touches "$shared"; then
  mise run server:lint
  mise run server:test
  ran=true
fi
if touches '^ios/' || touches "$shared"; then
  mise run ios:lint
  mise run ios:test
  ran=true
fi
"$ran" || echo "No server or iOS changes; nothing to check."
