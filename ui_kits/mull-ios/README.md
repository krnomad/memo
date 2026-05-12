# 흘려쓰기 · Find Later — iOS UI Kit

The hi-fi iOS MVP mockup for an AI-organized notes app whose pitch is:

> 아무렇게나 써도 나중에 찾을 수 있는 메모앱
> *Write whatever you want. Find it later.*

## Files

- **`index.html`** — the deliverable. Opens a pan/zoom design canvas with all four screens side-by-side on iPhone frames, plus designer post-its calling out the UX intent.
- **`Components.jsx`** — shared atoms: `StatusBar`, `NavBarLarge`, `NavBarCompact`, `TabBar`, `SearchField`, `NoteCard`, `TagChip`, `CategoryDot`, `AIDot`, `ComposeFab`, `KoreanKeyboard`, `Phone` (iPhone 14 device shell).
- **`HomeScreen.jsx`** — recent notes list, time-grouped (오늘 / 이번 주 / 지난 주), FAB.
- **`ComposeScreen.jsx`** — the most important screen. Auto-focus textarea + Korean keyboard + minimal meta footer (category, tags, AI suggestion teaser).
- **`BrowseScreen.jsx`** — categories list + frequency-weighted tag cloud.
- **`SearchScreen.jsx`** — recent-search history, popular tags, natural-language search teaser, results with keyword highlight.
- **`screen-*.html`** — standalone wrappers (one per screen) for the Design System tab cards.
- **`_preview_all.html`** / **`_preview_compose.html`** — internal helpers for verifying renders; not part of the kit.

## Screen flow

```
  Home  ──(검색 field tap)──▶  Search
   │
   │ (FAB tap)
   ▼
 Compose  ──(저장 / 취소)──▶  Home
```

Plus the bottom tab bar switches Home ↔ Browse ↔ Search in two taps from anywhere. The MVP keeps the Home screen as both list and entry — no separate landing.

## Design notes

- **3-second rule** — the FAB on Home opens Compose directly into the textarea (auto-focus). No category step, no title step. Save is dim until you type; *Cancel* and *Save* are equally weighted because we don't want to nag.
- **Categories are optional** — default value is *선택 안 함*. The category picker is collapsed until tapped. The same goes for tags.
- **AI placeholder surfaces** — three of them: (1) sage dot on a note card, (2) inline italic teaser under tags on Compose, (3) a sage banner in Browse + Search. All static — no AI runs in MVP. The structure is in place so future work can light it up without redesigning.
- **No login, no folders, no sync UI, no markdown** — out of scope per brief.

## Tokens

Everything inherits from `/colors_and_type.css` at the project root. The kit references CSS custom properties via inline styles, so a token change at the root flows through with no re-edits here.

## Known limitations

- The Korean keyboard is a static stylized representation, not a working IME.
- Recent searches and search results are seeded with placeholder copy — replace with real data.
- Tag cloud sizing is hardcoded per tag in the demo (`sm | md | lg | xl`). In real product it would be derived from usage frequency.
