---
name: mull-design
description: Use this skill to generate well-branded interfaces and assets for Mull / 흘려쓰기 — a calm iOS-native AI notes app — whether for production code or throwaway prototypes, mocks, and slide decks. Contains essential design guidelines, color and type tokens, fonts, icons, and a reference iOS UI kit (Home / Compose / Browse / Search).
user-invocable: true
---

Read the `README.md` file at the root of this skill, then explore the other files:

- `colors_and_type.css` — CSS custom properties for the full system (paper/ink palette, terracotta accent, sage AI tint, iOS HIG type scale, spacing/radii/shadow/motion tokens). Import this file at the top of any HTML artifact you produce.
- `preview/` — small specimen cards (one concept each) that show how the tokens look in use. Read these first when you need to *see* what a token feels like.
- `ui_kits/mull-ios/` — the working reference iOS app. `Components.jsx` is your component library; `HomeScreen.jsx` / `ComposeScreen.jsx` / `BrowseScreen.jsx` / `SearchScreen.jsx` are the canonical screens; `index.html` shows them side-by-side on a pan/zoom canvas.
- `assets/icons/ios/` — SVGs lifted from the iOS Human Interface Guidelines Figma source. Use these for status-bar glyphs and search icons. For app iconography in general, prefer Lucide (CDN) or SF Symbols (native) — see ICONOGRAPHY section of the main README.

## How to work in this brand

- **Tone** — calm, plain, unhurried, sentence case everywhere, no emoji in chrome. The voice is a thoughtful friend, never a startup deck.
- **Color** — warm paper backgrounds (never pure white as a page), warm ink text. One single accent (terracotta `#C46A3D`); never two. Sage (`#6E8B5A`) is reserved for AI surfaces.
- **Type** — Pretendard (Korean) / Geist (Latin) for UI; Newsreader italic serif for the wordmark, AI prose, and editorial display. Apple system fonts (`-apple-system`) take over on native iOS builds.
- **Layout** — iOS HIG. Large titles, grouped table views, 16px gutter, 44px tap targets minimum. Cards have 14px radius, controls 10px, no sharp corners anywhere except the page edge.
- **Motion** — settle, never bounce. Three easing curves, three durations (120/220/360ms). Fades over slides.
- **Iconography** — Lucide on web/prototypes; SF Symbols on native. Never hand-roll icons unless lifted from the iOS Figma source already in `assets/`.

## When invoked

If the user invokes this skill without specific guidance:

1. Ask what they want to build — a marketing page? a new screen for the iOS app? a deck? a settings panel?
2. Ask a few clarifying questions (variations? Korean or English? light/dark? device-framed mock or web?).
3. Build as a static HTML file when the deliverable is a visual artifact (mocks, slides, prototypes, throwaways). Reuse `Components.jsx` from the iOS UI kit when the work is iOS-shaped.
4. Build as production code (SwiftUI / React / etc.) when the user explicitly asks for production.

In both cases, copy assets out of this skill folder into the working project — do not reference them by path across project boundaries.

## Substitutions to flag

- Apple's **SF Pro / SF Mono** are not bundled (license-restricted). We use Pretendard + Geist as the open-source web fallback; native iOS uses the real system fonts automatically.
- **SF Symbols** is not bundled either; Lucide (`https://unpkg.com/lucide@latest/dist/umd/lucide.min.js`) is the substitute for web/static surfaces. For native iOS, swap each Lucide name for the SF Symbol equivalent listed in the ICONOGRAPHY table.
