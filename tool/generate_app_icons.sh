#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_ICON="${1:-$ROOT_DIR/assets/branding/app_icon.png}"

if [[ ! -f "$SOURCE_ICON" ]]; then
  echo "Source icon not found: $SOURCE_ICON" >&2
  exit 1
fi

if ! command -v magick >/dev/null 2>&1; then
  echo "ImageMagick is required: magick" >&2
  exit 1
fi

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

resize_png() {
  local source="$1"
  local target="$2"
  local size="$3"

  magick "$source" -resize "${size}x${size}" "$target"
}

# Android launcher icons.
resize_png "$SOURCE_ICON" "$ROOT_DIR/android/app/src/main/res/mipmap-mdpi/ic_launcher.png" 48
resize_png "$SOURCE_ICON" "$ROOT_DIR/android/app/src/main/res/mipmap-hdpi/ic_launcher.png" 72
resize_png "$SOURCE_ICON" "$ROOT_DIR/android/app/src/main/res/mipmap-xhdpi/ic_launcher.png" 96
resize_png "$SOURCE_ICON" "$ROOT_DIR/android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png" 144
resize_png "$SOURCE_ICON" "$ROOT_DIR/android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png" 192

# iOS app icons.
resize_png "$SOURCE_ICON" "$ROOT_DIR/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@1x.png" 20
resize_png "$SOURCE_ICON" "$ROOT_DIR/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@2x.png" 40
resize_png "$SOURCE_ICON" "$ROOT_DIR/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@3x.png" 60
resize_png "$SOURCE_ICON" "$ROOT_DIR/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@1x.png" 29
resize_png "$SOURCE_ICON" "$ROOT_DIR/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@2x.png" 58
resize_png "$SOURCE_ICON" "$ROOT_DIR/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@3x.png" 87
resize_png "$SOURCE_ICON" "$ROOT_DIR/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@1x.png" 40
resize_png "$SOURCE_ICON" "$ROOT_DIR/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@2x.png" 80
resize_png "$SOURCE_ICON" "$ROOT_DIR/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@3x.png" 120
resize_png "$SOURCE_ICON" "$ROOT_DIR/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@2x.png" 120
resize_png "$SOURCE_ICON" "$ROOT_DIR/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@3x.png" 180
resize_png "$SOURCE_ICON" "$ROOT_DIR/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@1x.png" 76
resize_png "$SOURCE_ICON" "$ROOT_DIR/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@2x.png" 152
resize_png "$SOURCE_ICON" "$ROOT_DIR/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-83.5x83.5@2x.png" 167
resize_png "$SOURCE_ICON" "$ROOT_DIR/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png" 1024

# macOS keeps the original transparent shape.
resize_png "$SOURCE_ICON" "$ROOT_DIR/macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_16.png" 16
resize_png "$SOURCE_ICON" "$ROOT_DIR/macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_32.png" 32
resize_png "$SOURCE_ICON" "$ROOT_DIR/macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_64.png" 64
resize_png "$SOURCE_ICON" "$ROOT_DIR/macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_128.png" 128
resize_png "$SOURCE_ICON" "$ROOT_DIR/macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_256.png" 256
resize_png "$SOURCE_ICON" "$ROOT_DIR/macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_512.png" 512
resize_png "$SOURCE_ICON" "$ROOT_DIR/macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_1024.png" 1024

# Web icons.
resize_png "$SOURCE_ICON" "$ROOT_DIR/web/favicon.png" 16
resize_png "$SOURCE_ICON" "$ROOT_DIR/web/icons/Icon-192.png" 192
resize_png "$SOURCE_ICON" "$ROOT_DIR/web/icons/Icon-512.png" 512
resize_png "$SOURCE_ICON" "$ROOT_DIR/web/icons/Icon-maskable-192.png" 192
resize_png "$SOURCE_ICON" "$ROOT_DIR/web/icons/Icon-maskable-512.png" 512

# Windows icon bundle.
magick "$SOURCE_ICON" -define icon:auto-resize=256,128,64,48,32,16 \
  "$ROOT_DIR/windows/runner/resources/app_icon.ico"

# OpenHarmony icons.
resize_png "$SOURCE_ICON" "$ROOT_DIR/ohos/AppScope/resources/base/media/app_icon.png" 114
resize_png "$SOURCE_ICON" "$ROOT_DIR/ohos/entry/src/main/resources/base/media/icon.png" 114
