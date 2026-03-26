#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/package_linux_common.sh"

BUNDLE_DIR="${1:?bundle dir required}"
OUTPUT_FILE="${2:?output file required}"
APPIMAGE_ARCH="${3:?appimage arch required}"

package_linux_validate_inputs "${BUNDLE_DIR}"

case "${APPIMAGE_ARCH}" in
  x86_64|x64)
    TOOL_ARCH="x86_64"
    ;;
  aarch64|arm64)
    TOOL_ARCH="aarch64"
    ;;
  *)
    echo "Unsupported AppImage arch: ${APPIMAGE_ARCH}" >&2
    exit 1
    ;;
esac

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

APPDIR="${TMP_DIR}/AppDir"
APP_ROOT="${APPDIR}/usr/lib/${PACKAGE_NAME}"
TOOL_DIR="${TMP_DIR}/tools"
APPIMAGETOOL_BIN="${TOOL_DIR}/appimagetool-${TOOL_ARCH}.AppImage"

mkdir -p \
  "${APP_ROOT}" \
  "${APPDIR}/usr/bin" \
  "${APPDIR}/usr/share/applications" \
  "${APPDIR}/usr/share/icons/hicolor/256x256/apps" \
  "${TOOL_DIR}"

package_linux_copy_bundle "${BUNDLE_DIR}" "${APP_ROOT}"
package_linux_copy_icon "${APPDIR}/${PACKAGE_NAME}.png"
package_linux_copy_icon "${APPDIR}/usr/share/icons/hicolor/256x256/apps/${PACKAGE_NAME}.png"
package_linux_write_launcher "${APPDIR}/usr/bin/${PACKAGE_NAME}" "/usr/lib/${PACKAGE_NAME}"
package_linux_write_desktop_file \
  "${APPDIR}/${PACKAGE_NAME}.desktop" \
  "${PACKAGE_NAME}" \
  "${PACKAGE_NAME}"
package_linux_write_desktop_file \
  "${APPDIR}/usr/share/applications/${PACKAGE_NAME}.desktop" \
  "${PACKAGE_NAME}" \
  "${PACKAGE_NAME}"
package_linux_try_fix_rpath "${APP_ROOT}" || true

cat > "${APPDIR}/AppRun" <<'EOF'
#!/bin/sh
APPDIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
APP_ROOT="${APPDIR}/usr/lib/husheng"
export LD_LIBRARY_PATH="${APP_ROOT}/lib${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"
exec "${APP_ROOT}/husheng" "$@"
EOF
chmod 755 "${APPDIR}/AppRun"

curl -fsSL \
  "https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-${TOOL_ARCH}.AppImage" \
  -o "${APPIMAGETOOL_BIN}"
chmod 755 "${APPIMAGETOOL_BIN}"

mkdir -p "$(dirname "${OUTPUT_FILE}")"
"${APPIMAGETOOL_BIN}" --appimage-extract-and-run "${APPDIR}" "${OUTPUT_FILE}"
