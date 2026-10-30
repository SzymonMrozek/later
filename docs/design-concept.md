# Later: core design concept

Source of truth for screens: the Design canvas, page "MVP flows":
https://claude.ai/artifact/KQQq1uvnpcBwjmzsCbtiqx

## Direction "E"

| | |
|---|---|
| Look | Variant A: white, calm, lots of air, one blue accent `#2449D8` |
| Flow | Variant B: time first. "Ile masz czasu?" → queue → session player |
| Copy | Polish UI; article content stays in its own language until translated |

## Principles

1. **Time before content.** The home screen asks how much time you have and builds the queue to fit.
2. **Two forms of every article.** Each article has a summary (skrót) and a full version (całość), and both show their length in minutes.
3. **Serif belongs to the article.** Source Serif 4 is used only for article titles and article text. Everything else (screen titles, numbers, buttons, logo) uses Instrument Sans.
4. **One accent.** Blue is the only accent: selection, progress and the primary action. Green means ready or offline, orange means a warning.
5. **Show where it came from.** Every article shows its lead image and its source icon, with a favicon tile as the fallback.
6. **Never block on the account.** You can start without logging in.

## Flows (17 screens)

```
1 First run      1.1 Welcome ─ 1.2 Languages & voice ─ 1.3 How to save
2 Save a link    2.1 Share sheet · 2.2 Paste link · 2.3 Preparing ─ 2.4 Partial content
3 Listen         3.1 How much time? ─ 3.2 Choose form ─ 3.3 Session player ─ 3.4 Queue
4 Read           4.1 Library ─ 4.2 Reader ─ 4.3 Edit categories
5 Plan           5.1 Limit reached ─ 5.2 Later+ · 5.3 Settings
```

## Decisions from review (2026-10-30)

| Topic | Decision |
|---|---|
| Languages | Multi-select with one **main** language. Articles in any chosen language play in the original; everything else is translated into the main one. |
| Login | "Wypróbuj bez konta" next to Sign in with Apple. The app uses an anonymous device account, and signing in later merges the library. StoreKit purchases don't need our login. |
| Saving | Mainly through the iOS Share Extension: a small panel over the source app that confirms the save and lets you pick summary or full and whether to download now. Pasting a link in the app is the fallback. |
| Speed | Preset buttons 1,0× · 1,1× · 1,25× · 1,5×, never a slider. |
| Images | The lead image (`og:image`) is shown in lists, as the hero in the reader and on the form-choice screen, and as artwork in the player and on the lock screen. |
| Source icon | The site's favicon next to the source name. Without an image, the thumbnail shows a grey tile with a large favicon. |
| Categories | Assigned automatically after saving. Edit them per article from the category chip in the Reader, or long-press a row and pick "Zmień kategorie". |

## Open

- A screen for managing the category list (rename, merge, delete): is it needed in the MVP?
- Prices, the free limit and the renewal date (placeholders on 5.1–5.3).
- A guest variant of Settings with a "Połącz konto" row.
