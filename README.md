# Mull · 흘려쓰기 — Design System

**Mull** is the internal/brand name for a calm AI-powered notes app for messy thinkers. The shipping product name in this MVP is **흘려쓰기** (literally *writing loosely* — *Find Later* in English). The pitch:

> 아무렇게나 써도 나중에 찾을 수 있는 메모앱
> *Write whatever you want. Find it later.*

Capture thoughts without structure — the app organizes, summarizes, and connects your notes using context-aware AI (planned post-MVP). Designed with native iOS interaction patterns, spacious layouts, and minimal visual noise.

The system in this folder is the *design vocabulary* (Mull) and the MVP product is the *first vessel* for it (흘려쓰기). Future products in this house (e.g. a marketing site, a watch companion) should share the same vocabulary.

---

## Sources

This system was assembled from one attached design source:

- **iOS Design System (Community)** — a Figma reference of Apple's iOS Human Interface Guidelines. Mounted in this project as the read-only `.fig` virtual filesystem (7 pages: Cover, Downloads, Wallpaper, Typography, Colors, Keyboards, Components — 29 top-level frames across 23 component categories). It is the *interaction & layout* source of truth: status bars, table views, navigation bars, tab bars, segmented pickers, action sheets, switches, alerts, keyboards. Mull does not re-invent these chrome elements.

There is no codebase yet — Mull is greenfield. The product brand identity in this document (palette, typography, voice, motifs) is original work layered on top of those iOS interaction primitives.

---

## Index — what's in this folder

```
README.md                     ← you are here
SKILL.md                      ← portable instructions for Claude Code / agents
colors_and_type.css           ← all design tokens (CSS custom properties)

assets/
  icons/ios/                  ← SVGs lifted from the iOS Figma reference
                                (status bar, search, microphone, scribble…)

preview/                      ← cards that render in the Design System tab
  _preview.css                ← shared chrome for previews
  brand-*.html                ← wordmark, app icon
  colors-*.html               ← paper/ink, accent, iOS system
  type-*.html                 ← display, titles, body
  spacing-scale.html · radii.html · shadows.html · motion.html
  component-*.html            ← buttons, inputs, table rows, nav bar,
                                tab bar, AI banner, tags, segmented

ui_kits/
  mull-ios/                   ← 흘려쓰기 iOS MVP UI kit
    README.md
    index.html                ← pan/zoom canvas with all four screens
    Components.jsx            ← shared atoms (Phone, NavBar, TabBar, …)
    HomeScreen.jsx
    ComposeScreen.jsx
    BrowseScreen.jsx
    SearchScreen.jsx
    screen-*.html             ← standalone wrappers (one per screen)
```

---

## CONTENT FUNDAMENTALS

Mull's voice is the voice of a thoughtful friend who happens to be very organized. It never sounds like software talking.

### Tone
- **Calm and unhurried.** Never urgent. No exclamation points except in user-generated content. The app rarely interrupts; when it does, it whispers.
- **Plain, warm, specific.** Short Anglo-Saxon words over Latinate ones — *fix*, not *resolve*; *find*, not *retrieve*; *tidy*, not *organize* (when speaking to the user). The product name uses "organize" because that's what it does — the *copy* prefers softer verbs.
- **Confident, never clever.** No puns, no winks, no startup-deck enthusiasm. The product takes its job seriously without taking itself seriously.

### Casing
- **Sentence case for everything**: buttons, menu items, section titles, settings rows. Never Title Case in the UI. *("New note"* — not *"New Note"*.)
- **Headings in the marketing site** also sentence-case. iOS's "Large Title" navigation header is the only exception that capitalises proper nouns aggressively, because that's iOS convention.
- The brand wordmark **Mull** is set lowercase italic serif: *mull*.

### Person
- **Second person, soft.** The app addresses the user as *you*. It refers to itself by name (*"Mull noticed…"*) or, sparingly, in the first person plural when explaining a system behavior (*"We keep your notes on-device"*). Avoid bare *I* — the app is not a person.
- The user's content is always *your notes*, *your thinking*, *your week*. Possessive, but quiet about it.

### Emoji
- **Not used in product chrome.** No emoji in section headers, empty states, system messages, button labels, or notifications.
- Allowed in user-generated note content (users type what they want).
- The brand never reaches for a 🚀 or a ✨ to imply AI. Smartness is shown by what the app *does*, not by stickering it.

### Examples
```
✅ Empty state, notes list
   You haven't written anything yet.
   Tap the pencil to start.

❌ Don't
   You don't have any notes! ✨ Let's get started 🚀

✅ AI summary banner
   Mull noticed three notes about the kitchen renovation.
   Group them? · Maybe later

❌ Don't
   AI MAGIC ✨ — Smart Group Detected! Click to organize.

✅ Push notification
   Two thoughts from last Tuesday seemed related.

❌ Don't
   🔔 Hey! Don't forget — we found a connection!

✅ Button labels
   Save · Done · Add tag · Move to journal · Discard

❌ Don't
   SAVE NOTE · Got it! · + Add a Tag · Move Note to Journal
```

### Microcopy patterns
- **Empty states** are single sentences plus a quiet instruction. No illustrations of cartoon people.
- **Errors** name what happened in plain language and offer the next move. No "Something went wrong" — *"Couldn't reach the server. Your note is saved locally."*
- **AI affordances** use the verb *noticed*: *"Mull noticed…"* — never *"AI detected"* or *"Suggested for you"*.

---

## VISUAL FOUNDATIONS

### Color
Mull rejects iOS's default cobalt blue tint for everything user-facing. The palette is built around **paper and ink** with one warm accent.

- **Paper** (`#F6F2EA`) is the default app background. It's the colour of a moleskine page in afternoon light — warm, not white. White is reserved for *cards* and *modal sheets* (so they read as paper laid on paper).
- **Ink** (`#1B1A17`) is the primary text. Almost black, but with enough warm undertone that black-on-paper never looks digital.
- **Terracotta** (`#C46A3D`) is the sole brand accent. It tints primary actions, the cursor, selected tags, the wordmark. Used *once or twice per screen*, never as a fill across whole regions.
- **Sage** (`#6E8B5A`) is the AI tint — reserved for AI-generated summaries, "Mull noticed" prompts, and links between connected notes. It must never be used for primary actions.
- iOS system colors (red, green, yellow, etc.) are kept *only* for system chrome where iOS conventions apply: destructive actions, switches, swipe-to-delete.

See `colors_and_type.css` for exact values.

### Typography
- **Display & note titles**: *Newsreader* (Google Fonts) — a calm, low-contrast variable serif. Italic for emphasis and the wordmark. Used at large sizes only.
- **UI body, lists, chrome**: *Geist* (Google Fonts) — a clean modern sans. Substitutes for SF Pro Text on web/Android; on iOS the system stack (`-apple-system`) takes over.
- **Mono**: *Geist Mono* for code blocks and tags.

**Substitution note → user**: The Figma source uses SF Pro Text / SF Pro Display / SF Mono (Apple system fonts, license-restricted). I've substituted **Geist** and **Geist Mono** as the nearest open-source matches for web surfaces, and added **Newsreader** as the brand display serif (the original iOS HIG doesn't have a brand serif — this is original to Mull). If you have a licensed SF Pro distribution for native iOS builds, please drop the `.otf` files into `fonts/` and update `--font-ui` in `colors_and_type.css`.

### Spacing
4px base grid. Use `--s-*` tokens. The iOS gutter is 16px (`--s-4`) on both edges; respect it. Vertical rhythm in the notes list uses 11px row padding (iOS table row spec), not the 4px grid — table rows are sacred.

### Backgrounds
- **No gradients** beyond the protection gradients under fixed nav/tab bars.
- **No full-bleed photography** in product surfaces. The marketing site may use one editorial photo (warm, daylit, papers/desks/hands — never people's faces).
- **No repeating textures, patterns, or noise.** Paper colour does all the texturing.
- **No hand-drawn illustrations.** The serif type is the warmth.
- Frosted blur (`backdrop-filter: blur(20px)` over `rgba(246,242,234,0.78)`) on nav bars when content scrolls beneath. Standard iOS behaviour.

### Animation
- **Easing**: `cubic-bezier(0.32, 0.72, 0, 1)` (iOS sheet feel) for sheet presentations and large transitions. `cubic-bezier(0.4, 0, 0.2, 1)` for everything else.
- **Durations**: 120ms fast, 220ms base, 360ms slow. Never longer than 400ms.
- **No bounces, springs that overshoot, or wobbles.** Mull doesn't bounce — it settles.
- **Fades** dominate. Slide-up for sheets, cross-fade for tab content, opacity for hover/press.

### Hover & press states
- Web hover: subtle `background: var(--paper-200)` fill, no border colour shift.
- iOS press: 30% opacity dim on the entire row/button for the duration of the touch (standard `UITableViewCellSelectionStyle = .default`).
- No scale transforms on press. No drop-shadow lift. Calm.

### Borders & dividers
- All dividers are 0.5px (or 1px CSS hairline) `--paper-300`, full-bleed inside their group with a 16px inset on the left where appropriate (iOS table-row separator inset).
- Cards have no border by default — they sit on paper and are distinguished by `--bg-card` (white) against paper.
- Outlined inputs use a 1px `--line-strong` border, never a coloured outline.

### Shadows
Restrained, almost a non-feature. The system uses *four* shadows:
- `--shadow-hairline` — 0.5px ring; for cards that need a border without a colour shift.
- `--shadow-card` — barely-there 2-layer drop; for note cards on paper.
- `--shadow-sheet` — upward shadow for bottom sheets.
- `--shadow-pop` — for context menus, popovers, action sheets.

No inner shadows. No coloured shadows. No glow effects.

### Protection gradients vs capsules
- iOS nav bar uses a **frosted capsule** (frosted bg + hairline divider underneath) when scrolled.
- Tab bar similarly. No "protection gradients" (the iPhone Music-style image-bleeding) — Mull never has imagery behind chrome.

### Layout rules
- **Fixed**: status bar (44px), navigation bar (44px or 96px large), tab bar (83px including home indicator).
- **Scrolling**: everything between.
- Content respects `--safe-top` and `--safe-bottom`. Always.
- Large-title navigation collapses to inline title on scroll (standard iOS).
- One column. Always. Side-by-side multi-pane layouts are not in scope.

### Transparency & blur
- Only on **chrome over scrolling content**: nav bars, tab bars, search-suggestions sheets.
- Never on cards or primary content surfaces (those are opaque white on paper).
- Modal scrim: `rgba(27, 26, 23, 0.32)` over an `8px` `backdrop-filter: blur(8px)`.

### Color vibe of imagery
- Warm-leaning, daylit, low-contrast. If the marketing site uses photography it must look like a window-lit desk — paper, hands, plants, mugs. No phones-with-screen, no stock office.
- Avatars are first-initial monograms on a warm tinted background. Photo avatars are allowed but cropped to a circle and presented at small sizes only.
- No greyscale-with-accent treatments.

### Corner radii
- Controls: 10px (iOS standard). Buttons, inputs, toggles container.
- Cards: 14px.
- Sheets: 14px top corners only (continuous, iOS-style).
- App icons: 22.37% — the iOS squircle ratio.
- Pills / tags: fully rounded (`--r-full`).
- **No sharp corners anywhere** except the page edge.

### Cards
A Mull card is:
- White (`--bg-card`) on paper background.
- 14px radius.
- 16px internal padding.
- A hairline (`box-shadow: 0 0 0 0.5px var(--line-1)`) OR `--shadow-card`, not both.
- No border-left accent stripes. Ever.

---

## ICONOGRAPHY

Mull uses **SF Symbols** as its icon library — the same icon family that ships with iOS — because it is what users already see in every other native app on their phone. SF Symbols sits inside the OS as a font; it cannot be redistributed via webfont, but it can be referenced by name in native code, and the relevant SF Symbol unicode glyphs (`􀯶`, `􀱢`, `􀝥`, `􀅒`) are present throughout the Figma source.

For non-native surfaces (web, slides, prototypes that need to render outside iOS) Mull uses **[Lucide](https://lucide.dev/)** as the substitute, via CDN. Lucide is line-only, 1.5px stroke, rounded caps — a close visual match for SF Symbols' default weight.

```html
<!-- Lucide via CDN, used in this project's HTML surfaces -->
<script src="https://unpkg.com/lucide@latest/dist/umd/lucide.min.js"></script>
```

**Substitution note → user**: If you can distribute SF Symbols (you're shipping an iOS-only product) please replace Lucide references with `<Image systemName="…">` in SwiftUI / `UIImage(systemName:)` in UIKit. The Lucide names below have native equivalents:

| Used as | Lucide name | SF Symbol |
|---|---|---|
| Search | `search` | `magnifyingglass` |
| New note | `pencil-line` | `square.and.pencil` |
| Voice capture | `mic` | `mic.fill` |
| AI / sparkle | `sparkle` | `sparkle` |
| Tag | `tag` | `tag` |
| Connection | `link-2` | `link` |
| Back | `chevron-left` | `chevron.backward` |
| More | `more-horizontal` | `ellipsis.circle` |
| Settings | `settings` | `gearshape` |

A handful of SVGs were extracted from the Figma source for direct use in static HTML / slides — see `assets/icons/ios/`. These are exact lifts of the iOS reference and should not be re-drawn by hand.

### What Mull does *not* use as iconography
- **No emoji** in chrome (see Content Fundamentals).
- **No unicode block characters** as icons (no `★`, no `→` as a chevron).
- **No multicolor icons.** Single-stroke or single-fill only.
- **No icon-only buttons without labels** outside the standard iOS toolbar slots (back, search, more). Anywhere else, label the icon.

---

## CAVEATS — please review

- **Two names in play.** *Mull* is the design-vocabulary name I invented when only the English brief existed. *흘려쓰기* is the Korean product name chosen for the MVP screens. Pick one to canonicalize and I'll find/replace. Other candidates from the brief: 막메모, 나중에찾기, Messy Notes, Find Later.
- **SF Pro / SF Mono are not bundled** (Apple license). Web/marketing falls back to **Pretendard + Geist**; native iOS gets the real fonts via `-apple-system`. If you have a licensed SF distribution drop the `.otf` files into `fonts/` and update `--font-ui` in `colors_and_type.css`.
- **The Korean keyboard in `ComposeScreen.jsx` is a static stylized representation**, not a working IME. Fine for mockups, wrong for engineering handoff.
- **No real product copy.** All Korean note titles, previews, and tags in the screens are placeholders I wrote in the Mull voice. Substitute beta-user content when available.
- **AI features are non-functional.** The three placeholder surfaces (note-card dot, compose teaser, browse/search banners) are UI only — no requests, no model calls, no logic.
- **One device size.** All mockups are iPhone 14 / 15 (390 × 844). iPad and small-iPhone variants are not in scope yet.

## Things I would love your input on

1. **Name** — confirm *흘려쓰기* or pick a different candidate.
2. **Accent color** — does terracotta land for you, or should I explore the Apple-Notes-yellow / Bear-red / Things-blue directions? Easy to swap.
3. **AI placeholder treatment** — sage tint and italic serif feels distinctly editorial. If you want it more "techy" (gradient, sparkle iconography) say so.
4. **Tab bar shape** — currently 3 tabs (최근 / 탐색 / 검색). The brief implies search and browse are the two "find later" surfaces; I split them. Combine them into one if you'd rather.
5. **Compose screen meta footer** — currently shows category + tags inline. Some teams prefer a single "옵션" button that opens a sheet. Either works; tell me your read.
