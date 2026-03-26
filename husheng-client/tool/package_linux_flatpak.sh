#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/package_linux_common.sh"

BUNDLE_DIR_INPUT="${1:?bundle dir required}"
OUTPUT_FILE="${2:?output file required}"
VERSION="${3:?version required}"
FLATPAK_ARCH="${4:-$(flatpak --default-arch)}"

BUNDLE_DIR="$(cd "${BUNDLE_DIR_INPUT}" && pwd)"

package_linux_validate_inputs "${BUNDLE_DIR}"

case "${FLATPAK_ARCH}" in
  x86_64|aarch64)
    ;;
  *)
    echo "Unsupported Flatpak arch: ${FLATPAK_ARCH}" >&2
    exit 1
    ;;
esac

if ! command -v flatpak-builder >/dev/null 2>&1; then
  echo "flatpak-builder not found." >&2
  exit 1
fi

APP_ID="com.aiitvisionlab.husheng"
RUNTIME_VERSION="${FLATPAK_RUNTIME_VERSION:-24.08}"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

BUILD_DIR="${TMP_DIR}/build"
REPO_DIR="${TMP_DIR}/repo"
STAGE_DIR="${TMP_DIR}/stage"
STATE_DIR="${TMP_DIR}/state"
MANIFEST_FILE="${TMP_DIR}/${APP_ID}.yml"
mkdir -p "${BUILD_DIR}" "${REPO_DIR}" "${STAGE_DIR}" "${STATE_DIR}"

package_linux_try_fix_rpath "${BUNDLE_DIR}" || true

if command -v magick >/dev/null 2>&1; then
  magick "$(package_linux_icon_source)" -resize 512x512 "${STAGE_DIR}/${APP_ID}.png"
else
  package_linux_copy_icon "${STAGE_DIR}/${APP_ID}.png"
fi

cat > "${STAGE_DIR}/launcher.sh" <<'EOF'
#!/bin/sh
APP_ROOT="/app/opt/husheng"
export LD_LIBRARY_PATH="${APP_ROOT}/lib${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"
exec "${APP_ROOT}/husheng" "$@"
EOF
chmod 755 "${STAGE_DIR}/launcher.sh"

package_linux_write_desktop_file \
  "${STAGE_DIR}/${APP_ID}.desktop" \
  "husheng" \
  "${APP_ID}"

cat > "${STAGE_DIR}/${APP_ID}.appdata.xml" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<component type="desktop-application">
  <id>${APP_ID}</id>
  <name>${APP_NAME}</name>
  <summary>${APP_COMMENT}</summary>
  <metadata_license>CC0-1.0</metadata_license>
  <project_license>Proprietary</project_license>
  <launchable type="desktop-id">${APP_ID}.desktop</launchable>
  <description>
    <p>斛生跨平台客户端。</p>
  </description>
  <releases>
    <release version="${VERSION}" date="$(date +%F)"/>
  </releases>
</component>
EOF

cat > "${MANIFEST_FILE}" <<EOF
app-id: ${APP_ID}
runtime: org.freedesktop.Platform
runtime-version: '${RUNTIME_VERSION}'
sdk: org.freedesktop.Sdk
command: husheng
finish-args:
  - --share=network
  - --share=ipc
  - --socket=fallback-x11
  - --socket=wayland
  - --socket=pulseaudio
  - --device=dri
modules:
  - name: husheng
    buildsystem: simple
    build-commands:
      - install -d /app/opt/husheng /app/bin /app/share/applications /app/share/icons/hicolor/256x256/apps /app/share/metainfo
      - cp -a bundle/. /app/opt/husheng/
      - install -Dm755 launcher.sh /app/bin/husheng
      - install -Dm644 ${APP_ID}.desktop /app/share/applications/${APP_ID}.desktop
      - install -Dm644 ${APP_ID}.png /app/share/icons/hicolor/256x256/apps/${APP_ID}.png
      - install -Dm644 ${APP_ID}.appdata.xml /app/share/metainfo/${APP_ID}.appdata.xml
    sources:
      - type: dir
        path: ${BUNDLE_DIR}
        dest: bundle
      - type: file
        path: ${STAGE_DIR}/launcher.sh
      - type: file
        path: ${STAGE_DIR}/${APP_ID}.desktop
      - type: file
        path: ${STAGE_DIR}/${APP_ID}.png
      - type: file
        path: ${STAGE_DIR}/${APP_ID}.appdata.xml
EOF

flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install --user --noninteractive --arch="${FLATPAK_ARCH}" flathub \
  "org.freedesktop.Platform//${RUNTIME_VERSION}" \
  "org.freedesktop.Sdk//${RUNTIME_VERSION}"

mkdir -p "$(dirname "${OUTPUT_FILE}")"
flatpak-builder \
  --user \
  --force-clean \
  --arch="${FLATPAK_ARCH}" \
  --default-branch=stable \
  --state-dir="${STATE_DIR}" \
  --repo="${REPO_DIR}" \
  "${BUILD_DIR}" \
  "${MANIFEST_FILE}"
flatpak build-bundle \
  --arch="${FLATPAK_ARCH}" \
  "${REPO_DIR}" \
  "${OUTPUT_FILE}" \
  "${APP_ID}" \
  stable
