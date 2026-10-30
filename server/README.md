# Later server

Phoenix JSON API, Ecto + Postgres, Oban jobs. Run it from the repository root:

```bash
mise run server:dev    # http://localhost:$PORT/api/health
mise run server:test
mise run server:lint   # format, warnings as errors, Credo strict, Sobelow
```

Each worktree uses its own `PORT` and `LATER_DB_NAME`; see the root [AGENTS.md](../AGENTS.md).
