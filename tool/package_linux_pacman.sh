#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/package_linux_common.sh"

BUNDLE_DIR="${1:?bundle dir required}"
OUTPUT_FILE="${2:?output file required}"
VERSION="${3:?version required}"
PKGREL="${4:-1}"
PACMAN_ARCH="${5:?pacman arch required}"

package_linux_validate_inputs "${BUNDLE_DIR}"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

PKG_ROOT="${TMP_DIR}/pkg"
mkdir -p \
  "${PKG_ROOT}${INSTALL_ROOT}" \
  "${PKG_ROOT}/usr/bin" \
  "${PKG_ROOT}/usr/share/applications" \
  "${PKG_ROOT}/usr/share/icons/hicolor/256x256/apps"

package_linux_copy_bundle "${BUNDLE_DIR}" "${PKG_ROOT}${INSTALL_ROOT}"
package_linux_copy_icon "${PKG_ROOT}/usr/share/icons/hicolor/256x256/apps/${PACKAGE_NAME}.png"
package_linux_write_launcher "${PKG_ROOT}/usr/bin/${PACKAGE_NAME}" "${INSTALL_ROOT}"
package_linux_write_desktop_file \
  "${PKG_ROOT}/usr/share/applications/${PACKAGE_NAME}.desktop" \
  "${PACKAGE_NAME}" \
  "${PACKAGE_NAME}"
package_linux_try_fix_rpath "${PKG_ROOT}${INSTALL_ROOT}" || true

BUILD_DATE="$(date +%s)"
INSTALLED_SIZE="$(du -sb "${PKG_ROOT}" | awk '{print $1}')"

cat > "${PKG_ROOT}/.PKGINFO" <<EOF
pkgname = ${PACKAGE_NAME}
pkgbase = ${PACKAGE_NAME}
pkgver = ${VERSION}-${PKGREL}
pkgdesc = ${APP_COMMENT}
url = ${PACKAGE_URL}
builddate = ${BUILD_DATE}
packager = AIITVisionLab
size = ${INSTALLED_SIZE}
arch = ${PACMAN_ARCH}
license = Proprietary
depend = glibc
depend = gtk3
depend = libsecret
depend = alsa-lib
depend = libpulse
depend = libglvnd
EOF

cat > "${PKG_ROOT}/.BUILDINFO" <<EOF
format = 2
pkgname = ${PACKAGE_NAME}
pkgbase = ${PACKAGE_NAME}
pkgver = ${VERSION}-${PKGREL}
pkgarch = ${PACMAN_ARCH}
pkgbuild_sha256sum = SKIPPED
packager = AIITVisionLab
builddate = ${BUILD_DATE}
builddir = $(package_linux_root_dir)
EOF

mkdir -p "$(dirname "${OUTPUT_FILE}")"
OUTPUT_ABS="$(cd "$(dirname "${OUTPUT_FILE}")" && pwd)/$(basename "${OUTPUT_FILE}")"
(
  cd "${PKG_ROOT}"
  fakeroot tar \
    --sort=name \
    --zstd \
    --owner=0 \
    --group=0 \
    --numeric-owner \
    -cf "${OUTPUT_ABS}" \
    .PKGINFO \
    .BUILDINFO \
    opt \
    usr
)
