#!/usr/bin/env bash
# Worktrunk pre-remove hook: drops this worktree's databases and deletes its simulator.
set -euo pipefail

db=""
if [ -f mise.local.toml ]; then
  db="$(sed -n 's/^LATER_DB_NAME = "\(.*\)"$/\1/p' mise.local.toml)"
fi

if [ -n "$db" ] && docker compose ps --status running --quiet postgres 2>/dev/null | grep -q .; then
  for suffix in dev test; do
    docker compose exec -T postgres dropdb -U postgres --if-exists --force "${db}_${suffix}"
  done
fi

if [ -f .worktree-simulator/simulator.env ]; then
  python3 tools/pitcrew/worktree-simulator/worktree_simulator.py delete
fi
