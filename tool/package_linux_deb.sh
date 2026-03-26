#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/package_linux_common.sh"

BUNDLE_DIR="${1:?bundle dir required}"
OUTPUT_FILE="${2:?output file required}"
VERSION="${3:?version required}"
DEB_ARCH="${4:?deb arch required}"

package_linux_validate_inputs "${BUNDLE_DIR}"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

PKG_ROOT="${TMP_DIR}/pkg"
mkdir -p \
  "${PKG_ROOT}/DEBIAN" \
  "${PKG_ROOT}${INSTALL_ROOT}" \
  "${PKG_ROOT}/usr/bin" \
  "${PKG_ROOT}/usr/share/applications" \
  "${PKG_ROOT}/usr/share/icons/hicolor/256x256/apps"

package_linux_copy_bundle "${BUNDLE_DIR}" "${PKG_ROOT}${INSTALL_ROOT}"
package_linux_copy_icon "${PKG_ROOT}/usr/share/icons/hicolor/256x256/apps/${PACKAGE_NAME}.png"
package_linux_try_fix_rpath "${PKG_ROOT}${INSTALL_ROOT}" || true

cat > "${PKG_ROOT}/DEBIAN/control" <<EOF
Package: ${PACKAGE_NAME}
Version: ${VERSION}
Section: utils
Priority: optional
Architecture: ${DEB_ARCH}
Maintainer: AIITVisionLab
Depends: libc6, libstdc++6, libgtk-3-0, libsecret-1-0, libasound2, libpulse0, libgl1, libx11-6
Description: 斛生跨平台客户端
EOF

package_linux_write_launcher "${PKG_ROOT}/usr/bin/${PACKAGE_NAME}" "${INSTALL_ROOT}"
package_linux_write_desktop_file \
  "${PKG_ROOT}/usr/share/applications/${PACKAGE_NAME}.desktop" \
  "${PACKAGE_NAME}" \
  "${PACKAGE_NAME}"

mkdir -p "$(dirname "${OUTPUT_FILE}")"
dpkg-deb --build --root-owner-group "${PKG_ROOT}" "${OUTPUT_FILE}"
