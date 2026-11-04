# Later

Save articles now, read or listen later, in full or as a summary, in your language.
Monorepo: `ios/` (SwiftUI app), `server/` (Elixir + Phoenix API), `docs/` (product and design).
A future `web/` sits next to them.

**This repository is public.** Never commit secrets, API keys, `.env` files, signing material,
or names from other private projects. Secrets come from the environment at runtime.

## Layout

| Path | What |
| --- | --- |
| `ios/` | Tuist project (`Project.swift`). The app target in `ios/Later` only starts `AppComposition`; everything else is a module in `ios/Modules` (architecture and rules: `ios/Modules/README.md`). |
| `server/` | Phoenix JSON API, Ecto + Postgres, Oban jobs. See `server/AGENTS.md` for Phoenix rules. |
| `docs/` | Product concept, design concept, the API contract (`docs/api.md`), architecture maps (`docs/maps.html`). |
| `scripts/` | Worktree hooks, iOS build/run, merge checks. |
| `tools/pitcrew` | Submodule: local-review and worktree-simulator, pinned to a tag. |

## Commands

All tools are pinned in `mise.toml`. `mise run setup` once after cloning.

| Task | Command |
| --- | --- |
| API on this worktree's port and database | `mise run server:dev` |
| Server tests / lint | `mise run server:test` · `mise run server:lint` |
| App on this worktree's simulator | `mise run ios:run` |
| iOS tests / lint | `mise run ios:test` · `mise run ios:lint` |
| What the merge queue runs | `mise run check` |

## Worktrees

Work happens in [Worktrunk](https://github.com/max-sixty/worktrunk) worktrees (`wt switch -c <branch>`).
Each worktree gets its own Phoenix `PORT`, Postgres databases (`LATER_DB_NAME`) and iOS Simulator,
written to `mise.local.toml` and `.worktree-simulator/` by `.config/wt.toml`. Use the mise tasks,
which pick these up; never hardcode a port, database or simulator name. Postgres is one shared
container (`mise run db:up`).

## Conventions

- Elixir: `mix format`, Credo strict, no compiler warnings. Business logic in contexts under
  `server/lib/later/`, HTTP in `server/lib/later_web/`. Jobs are Oban workers.
- Swift: Swift 6 strict concurrency, SwiftUI, SwiftLint + SwiftFormat clean. Tests use Swift Testing.
- UI copy is Polish. Article titles and body text use Source Serif 4; all other UI uses Instrument Sans.
- Commit messages: Conventional Commits, `type(scope): summary`, scopes `ios`, `server`, `docs`, `tooling`.

## Before starting a task

Run `mise run review -- --queue`. It lists approved merges that haven't landed yet, with
their changed paths and private Git snapshots. Start unrelated work from the current `main`.
If a pending change affects your area, inspect its snapshot and bring the relevant changes into
your worktree. Never edit the worktree that's being merged.

## Code review and merging

Review uses [pitcrew local-review](tools/pitcrew/local-review/README.md). When the user starts a
review, run `mise run review` from the worktree being reviewed and give the user the printed URL.
Never open review or queue pages yourself. Read approvals, comments and merge status through the
review CLI.

The user's **Ask agent to merge** confirmation delegates completing the local merge to you.
Inspect it with `mise run review -- --merge-request <id>`, then run
`mise run review -- --execute-merge-request <id>`. Approval covers code corrections, failing
checks, rebasing and conflict resolution for the existing task; handle these and retry the same
request until it merges. Never merge a withdrawn approval. The Worktrunk pre-merge hook runs
`mise run check`; don't run it immediately beforehand on unchanged content.

## Review iterations

For every user interaction that changes the repository, before changing files run:

```bash
mise run review -- --begin-iteration <id> --request "<brief summary of this request>"
```

Before replying, write a description of the final branch change and its validation to a file, then:

```bash
mise run review -- --finish-iteration <id> --summary "<result>" \
  --title "feat(scope): describe the final change" \
  --description-file /absolute/path/to/description.txt
```

Include both printed URLs as **Full review** and **This iteration** links in your reply. The title
and description become the merged commit, so describe the final change, not the history.

## Demo recordings

When a change affects what people see in the app, launch it with `mise run ios:run` and record one
demo per scenario:

```bash
mise run review -- --record-demo "<scenario>"
# drive the app
mise run review -- --stop-demo
```

For changes under `ios/Later/` with no visible effect, run `mise run review -- --skip-demo "<reason>"`.
