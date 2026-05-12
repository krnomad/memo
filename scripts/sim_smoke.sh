#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"
export DEVELOPER_DIR

DEVICE="${1:-F2C6636B-F815-47D9-AA18-B78A87B7CE03}"
BUNDLE="com.krnomad.FindLater"
APP_DIR="$("$ROOT_DIR/scripts/build_sim.sh")"
OUT_DIR="$ROOT_DIR/screenshots/native"

mkdir -p "$OUT_DIR"

xcrun simctl boot "$DEVICE" >/dev/null 2>&1 || true
xcrun simctl bootstatus "$DEVICE" -b
xcrun simctl install "$DEVICE" "$APP_DIR"

capture() {
  local name="$1"
  shift
  xcrun simctl terminate "$DEVICE" "$BUNDLE" >/dev/null 2>&1 || true
  xcrun simctl launch "$DEVICE" "$BUNDLE" "$@"
  sleep 2
  xcrun simctl io "$DEVICE" screenshot "$OUT_DIR/$name.png"
}

capture home --reset-store
capture compose --reset-store --show-compose
capture smoke --reset-store --seed-smoke-memo
capture search --reset-store --seed-smoke-memo --search 민지
capture browse --reset-store --seed-smoke-memo --browse-category 업무

echo "screenshots written to $OUT_DIR"
