#!/usr/bin/env bash
# Worktrunk pre-start hook: gives this worktree its own Phoenix port, Postgres databases and
# iOS Simulator, recorded in mise.local.toml and .worktree-simulator/.
set -euo pipefail

while [ "$#" -gt 0 ]; do
  case "$1" in
    --db) db="$2"; shift 2 ;;
    --port) port="$2"; shift 2 ;;
    --simulator) simulator="$2"; shift 2 ;;
    *) echo "error: unknown argument: $1" >&2; exit 2 ;;
  esac
done

# New worktrees don't check out submodules; this reuses the clone in the git common dir.
git submodule update --init --quiet

cat > mise.local.toml <<TOML
# Written by scripts/worktree-setup.sh for this worktree only.
[env]
PORT = "${port:?--port is required}"
LATER_DB_NAME = "later_${db:?--db is required}"
TOML
mise trust --yes --quiet mise.local.toml

if command -v xcrun >/dev/null 2>&1; then
  python3 tools/pitcrew/worktree-simulator/worktree_simulator.py create --name "${simulator:?--simulator is required}" >/dev/null
fi
