# 흘려쓰기 native iOS app

This repo now contains the static web mockup and a native SwiftUI MVP app.

## Native MVP scope

- Quick memo creation
- Raw text persistence
- Manual tags
- Manual category selection
- Recent memo home view
- Browse by category and tag
- Search by raw text, title, category, and tag
- Sage-only placeholder surfaces for future AI suggestions and search

## Verify locally

The current machine has Xcode installed at `/Applications/Xcode.app`, but global `xcode-select` points to CommandLineTools. Because switching it requires sudo, the included scripts build with `swiftc` and run with `simctl` directly.

```sh
scripts/build_sim.sh
scripts/sim_smoke.sh
```

`scripts/sim_smoke.sh` writes screenshots to `screenshots/native/`:

- `home.png`
- `compose.png`
- `smoke.png`
- `search.png`
- `browse.png`

If your machine has `xcode-select` set to Xcode, the included `FindLater.xcodeproj` can also be opened in Xcode.
