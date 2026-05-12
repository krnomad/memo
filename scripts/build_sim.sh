#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"
export DEVELOPER_DIR

SDK="$(xcrun --sdk iphonesimulator --show-sdk-path)"
APP_DIR="$ROOT_DIR/build/ManualSim/FindLater.app"

rm -rf "$ROOT_DIR/build/ManualSim"
mkdir -p "$APP_DIR"

xcrun swiftc \
  -target arm64-apple-ios17.0-simulator \
  -sdk "$SDK" \
  -parse-as-library \
  "$ROOT_DIR/FindLater/FindLaterApp.swift" \
  "$ROOT_DIR/FindLater/Theme.swift" \
  "$ROOT_DIR/FindLater/Models/Memo.swift" \
  "$ROOT_DIR/FindLater/Models/MemoStore.swift" \
  "$ROOT_DIR"/FindLater/Views/*.swift \
  -o "$APP_DIR/FindLater"

cp "$ROOT_DIR/FindLater/Info.plist" "$APP_DIR/Info.plist"
/usr/bin/codesign --force --sign - "$APP_DIR"

echo "$APP_DIR"
