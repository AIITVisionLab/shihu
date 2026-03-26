#!/usr/bin/env bash
set -euo pipefail

APP_PATH="${1:?app path required}"
OUTPUT_IPA="${2:?output ipa required}"

if [[ ! -d "${APP_PATH}" ]]; then
  echo "App bundle not found: ${APP_PATH}" >&2
  exit 1
fi

OUTPUT_DIR="$(dirname "${OUTPUT_IPA}")"
OUTPUT_NAME="$(basename "${OUTPUT_IPA}")"
mkdir -p "${OUTPUT_DIR}"
OUTPUT_DIR="$(cd "${OUTPUT_DIR}" && pwd)"
OUTPUT_PATH="${OUTPUT_DIR}/${OUTPUT_NAME}"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

PAYLOAD_DIR="${TMP_DIR}/Payload"
mkdir -p "${PAYLOAD_DIR}"
ditto "${APP_PATH}" "${PAYLOAD_DIR}/$(basename "${APP_PATH}")"

(
  cd "${TMP_DIR}"
  ditto -c -k --sequesterRsrc --keepParent "Payload" "${OUTPUT_PATH}"
)
