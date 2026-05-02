#!/usr/bin/env bash
set -euo pipefail

APP_NAME="Notchlet"
PROJECT="Notchlet.xcodeproj"
SCHEME="Notchlet"
CONFIG="Debug"
DERIVED="./DerivedData"
APP_DEST="/Applications/${APP_NAME}.app"

xcodebuild \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -configuration "$CONFIG" \
  -derivedDataPath "$DERIVED" \
  build

APP_PATH=$(find "$DERIVED" -path "*Build/Products/${CONFIG}*" -name "${APP_NAME}.app" | head -1)

if [ -z "${APP_PATH:-}" ]; then
  echo "Could not find built app"
  exit 1
fi

rm -rf "$APP_DEST"
cp -R "$APP_PATH" "$APP_DEST"
open "$APP_DEST"