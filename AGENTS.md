# Repository Guidelines

## Project Structure & Module Organization

- `FindLater/` contains the native SwiftUI iOS app: `Models/`, `Views/`, `Theme.swift`, and `FindLaterApp.swift`.
- `FindLaterTests/` contains unit tests. `FindLaterUITests/` contains XCUITest flows.
- `index.html` and `slide.html` are static GitHub Pages artifacts.
- `ui_kits/mull-ios/`, `preview/`, and `assets/` contain the design system and static mockup references.
- `doc/` contains AI integration planning and contracts. Start with `doc/PLAN.md`.
- `scripts/` contains local helper scripts for simulator builds and smoke checks.

## Build, Test, and Development Commands

Use Xcode 26+ with iOS simulator/device support.

```bash
xcodebuild test \
  -project FindLater.xcodeproj \
  -scheme FindLater \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

Runs unit and UI tests.

```bash
./scripts/build_sim.sh
./scripts/sim_smoke.sh
```

Builds the simulator app and runs a smoke flow where available.

Static web files can be opened directly in a browser:

```bash
open index.html
open slide.html
```

## Coding Style & Naming Conventions

- Swift uses 4-space indentation and standard Swift naming.
- Types use `UpperCamelCase`; properties, functions, and enum cases use `lowerCamelCase`.
- Keep SwiftUI views small. Put reused UI in `FindLater/Views/MemoComponents.swift`.
- Preserve the app visual language: warm paper background, warm ink text, terracotta actions, sage AI placeholders.
- Do not introduce real AI calls directly in views; use the planned `AIService` / `AIAdapter` boundary.

## Testing Guidelines

- Unit tests use XCTest in `FindLaterTests/`.
- UI tests use XCUITest in `FindLaterUITests/`.
- Add tests for store behavior, persistence, search, delete, and AI states.
- Test names should describe behavior, e.g. `testDeleteMemoRemovesNoteAndPersists`.
- Run the full `xcodebuild test` command before installing to a device or pushing.

## Commit & Pull Request Guidelines

Commit history uses short imperative summaries, for example:

- `Improve memo navigation and search UX`
- `Document AI integration plan`

Keep commits focused. Include docs with the code when behavior or architecture changes.

PRs should include:

- Summary of user-visible changes
- Test commands and results
- Screenshots or simulator notes for UI changes
- Device-install notes when iPhone behavior changed

## Security & Configuration Tips

- The AI backend must remain behind the app/backend boundary described in `doc/AI-BACKEND.md`.
- Do not expose Codex CLI directly to the app.
- Keep backend URL/config values centralized.
- Do not commit build products, DerivedData, provisioning profiles, certificates, or local device logs.
