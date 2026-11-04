# Design system

The tokens and components of [`design/Later.canvas`](../../../design/Later.canvas) as SwiftUI,
one module per token set and per component family. A screen imports what it draws and nothing
else, so changing the scrubber rebuilds and re-tests only the scrubber and the screens that use it.

```text
Tokens       LaterColor  LaterTypography  LaterSpacing  LaterRadius  LaterSize  LaterStroke
                 ▲
             LaterShadow ◀── LaterGlass (also LaterStroke)

Components   each imports only the tokens it uses (see Project.swift), and these build on others:
             LaterArticleRow ──▶ LaterArticleThumb · LaterSourceIcon · LaterStatusTag
             LaterQueueRow   ──▶ LaterArticleThumb
             LaterMiniPlayer ──▶ LaterArticleThumb · LaterGlass
             LaterNavBar     ──▶ LaterIconButton

Review       LaterCatalog ──▶ everything; the app shows it after sign-in until the first signed-in scene lands
```

| Canvas | Swift |
| --- | --- |
| `color.text.ink` | `LaterColor.Text.ink` |
| `type.ui.headline`, weight on the text | `.font(.laterUI(.headline, weight: .semibold))` |
| `type.article.title` | `.font(.laterArticle(.title))`, only for the article's own title and text |
| `space.3` | `LaterSpacing.three` |
| `radius.lg`, `size.tap`, `stroke.selected` | `LaterRadius.lg`, `LaterSize.tap`, `LaterStroke.selected` |
| `shadow.glass*` with `color.overlay.shadowGlass` | `.laterShadow(.glass)` |
| Liquid Glass (`color.glass.*` on the canvas) | `.laterGlass(in: Capsule())` |
| `Button/Primary` | `LaterButton("Listen", variant: .primary) {}` |

## Rules

- Every import is declared in [`Project.swift`](../../Project.swift); `mise run ios:lint` runs
  `tuist inspect dependencies`, which fails on an undeclared or unused one.
- Colors and fonts come from `LaterColor` and `LaterTypography`. SwiftLint rejects `Color(red:)`,
  `.font(.body)` and the like everywhere else.
- Components take plain values (strings, minutes, `Image?`), not app models, and don't load
  anything themselves. Copy is passed in, except fixed units such as "min".
- A component used by one feature only moves into that feature once it exists.
- Settings rows use the system `Toggle`; the canvas's `Toggle` has no module of its own.

## Adding a module

Add a `.standalone(...)` to `uiComponents` in [`Project.swift`](../../Project.swift) with the modules it
imports, put its code in `Modules/UIComponents/<Name>/Sources` (and `Tests`, `Resources` if it has
them), show it on a [`LaterCatalog`](LaterCatalog/Sources) page, and run `mise run ios:generate`.
