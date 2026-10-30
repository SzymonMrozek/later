# Later

Save an article now. Later, read it or listen to it, in full or as a summary, in your own language.
The first use case: English articles, heard in Polish.

Built in public: an iPhone app in SwiftUI and an Elixir backend, developed with coding agents
working in parallel git worktrees. The product thinking is in [`docs/`](docs).

| | |
| --- | --- |
| [`ios/`](ios) | SwiftUI app, Tuist project |
| [`server/`](server) | Elixir · Phoenix · Ecto · Oban · Postgres |
| [`docs/`](docs) | Product concept, design concept, [architecture maps](docs/maps.html) |
| [`tools/pitcrew`](https://github.com/SzymonMrozek/pitcrew) | Local review, merge queue, per-worktree simulators |

## Run it

Requires macOS with Xcode, [mise](https://mise.jdx.dev) and Docker.

```bash
git clone --recurse-submodules <this repository>
cd later
mise install
mise run setup
mise run server:dev   # API on http://localhost:4000/api/health
mise run ios:run      # app on this worktree's simulator
```

## How it's developed

- Every task runs in its own [Worktrunk](https://github.com/max-sixty/worktrunk) worktree, with its
  own Phoenix port, Postgres databases and iOS Simulator (`.config/wt.toml`).
- Changes are reviewed locally with [pitcrew local-review](https://github.com/SzymonMrozek/pitcrew/tree/main/local-review)
  and land through one local merge queue; `mise run check` gates every merge.
- CI runs the same lint and tests per part of the monorepo.

Agent instructions live in [AGENTS.md](AGENTS.md).

## License

All rights reserved for now. The code is public to read and learn from.
