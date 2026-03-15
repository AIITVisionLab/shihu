#!/usr/bin/env bash
set -euo pipefail

BUNDLE_DIR="${1:?bundle dir required}"
OUTPUT_FILE="${2:?output file required}"
VERSION="${3:?version required}"
DEB_ARCH="${4:?deb arch required}"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ICON_SOURCE="${ROOT_DIR}/assets/branding/app_icon.png"
PACKAGE_NAME="husheng"
INSTALL_ROOT="/opt/${PACKAGE_NAME}"

if [[ ! -d "${BUNDLE_DIR}" ]]; then
  echo "Bundle directory not found: ${BUNDLE_DIR}" >&2
  exit 1
fi

if [[ ! -f "${ICON_SOURCE}" ]]; then
  echo "Icon not found: ${ICON_SOURCE}" >&2
  exit 1
fi

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

PKG_ROOT="${TMP_DIR}/pkg"
mkdir -p \
  "${PKG_ROOT}/DEBIAN" \
  "${PKG_ROOT}${INSTALL_ROOT}" \
  "${PKG_ROOT}/usr/bin" \
  "${PKG_ROOT}/usr/share/applications" \
  "${PKG_ROOT}/usr/share/icons/hicolor/256x256/apps"

cp -R "${BUNDLE_DIR}/." "${PKG_ROOT}${INSTALL_ROOT}/"
cp "${ICON_SOURCE}" "${PKG_ROOT}/usr/share/icons/hicolor/256x256/apps/${PACKAGE_NAME}.png"

cat > "${PKG_ROOT}/DEBIAN/control" <<EOF
Package: ${PACKAGE_NAME}
Version: ${VERSION}
Section: utils
Priority: optional
Architecture: ${DEB_ARCH}
Maintainer: AIITVisionLab
Description: 斛生跨平台客户端
EOF

cat > "${PKG_ROOT}/usr/bin/${PACKAGE_NAME}" <<EOF
#!/bin/sh
exec ${INSTALL_ROOT}/sickandflutter "\$@"
EOF
chmod 755 "${PKG_ROOT}/usr/bin/${PACKAGE_NAME}"

cat > "${PKG_ROOT}/usr/share/applications/${PACKAGE_NAME}.desktop" <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=斛生
Comment=斛生跨平台客户端
Exec=${INSTALL_ROOT}/sickandflutter
Icon=${PACKAGE_NAME}
Terminal=false
Categories=Utility;
Keywords=斛生;石斛;监控;
EOF

mkdir -p "$(dirname "${OUTPUT_FILE}")"
dpkg-deb --build --root-owner-group "${PKG_ROOT}" "${OUTPUT_FILE}"
