#!/usr/bin/env bash
set -euo pipefail

APP_PATH="${1:?app path required}"
OUTPUT_DMG="${2:?output dmg required}"

if [[ ! -d "${APP_PATH}" ]]; then
  echo "App bundle not found: ${APP_PATH}" >&2
  exit 1
fi

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

STAGE_DIR="${TMP_DIR}/dmg"
mkdir -p "${STAGE_DIR}"

ditto "${APP_PATH}" "${STAGE_DIR}/斛生.app"
ln -s /Applications "${STAGE_DIR}/Applications"

mkdir -p "$(dirname "${OUTPUT_DMG}")"
hdiutil create \
  -volname "斛生" \
  -srcfolder "${STAGE_DIR}" \
  -ov \
  -format UDZO \
  "${OUTPUT_DMG}"
