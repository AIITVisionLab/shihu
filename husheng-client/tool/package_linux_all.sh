#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

BUNDLE_DIR="${1:?bundle dir required}"
OUTPUT_DIR="${2:?output dir required}"
VERSION="${3:?version required}"
ARCH_PROFILE="${4:?arch profile required}"

case "${ARCH_PROFILE}" in
  x64)
    PACKAGE_LABEL="x64"
    DEB_ARCH="amd64"
    RPM_ARCH="x86_64"
    PACMAN_ARCH="x86_64"
    APPIMAGE_ARCH="x86_64"
    FLATPAK_ARCH="x86_64"
    ;;
  arm64)
    PACKAGE_LABEL="arm64"
    DEB_ARCH="arm64"
    RPM_ARCH="aarch64"
    PACMAN_ARCH="aarch64"
    APPIMAGE_ARCH="aarch64"
    FLATPAK_ARCH="aarch64"
    ;;
  loong64|loongarch64)
    PACKAGE_LABEL="loong64"
    DEB_ARCH="loong64"
    RPM_ARCH="loongarch64"
    PACMAN_ARCH="loong64"
    APPIMAGE_ARCH=""
    FLATPAK_ARCH=""
    ;;
  riscv64)
    PACKAGE_LABEL="riscv64"
    DEB_ARCH="riscv64"
    RPM_ARCH="riscv64"
    PACMAN_ARCH="riscv64"
    APPIMAGE_ARCH=""
    FLATPAK_ARCH=""
    ;;
  *)
    echo "Unsupported arch profile: ${ARCH_PROFILE}" >&2
    echo "Supported profiles: x64, arm64, loong64, riscv64" >&2
    exit 1
    ;;
esac

mkdir -p "${OUTPUT_DIR}"

"${SCRIPT_DIR}/package_linux_deb.sh" \
  "${BUNDLE_DIR}" \
  "${OUTPUT_DIR}/斛生-linux-${PACKAGE_LABEL}.deb" \
  "${VERSION}" \
  "${DEB_ARCH}"

"${SCRIPT_DIR}/package_linux_rpm.sh" \
  "${BUNDLE_DIR}" \
  "${OUTPUT_DIR}/斛生-linux-${PACKAGE_LABEL}.rpm" \
  "${VERSION}" \
  "${RPM_ARCH}"

"${SCRIPT_DIR}/package_linux_pacman.sh" \
  "${BUNDLE_DIR}" \
  "${OUTPUT_DIR}/斛生-linux-${PACKAGE_LABEL}.pkg.tar.zst" \
  "${VERSION}" \
  "1" \
  "${PACMAN_ARCH}"

"${SCRIPT_DIR}/package_linux_portable.sh" \
  "${BUNDLE_DIR}" \
  "${OUTPUT_DIR}/斛生-linux-${PACKAGE_LABEL}-portable.tar.gz" \
  "husheng-linux-${PACKAGE_LABEL}-portable"

if [[ -n "${APPIMAGE_ARCH}" ]]; then
  "${SCRIPT_DIR}/package_linux_appimage.sh" \
    "${BUNDLE_DIR}" \
    "${OUTPUT_DIR}/斛生-linux-${PACKAGE_LABEL}.AppImage" \
    "${APPIMAGE_ARCH}"
else
  echo "Skip AppImage for ${ARCH_PROFILE}: upstream appimagetool is unavailable for this arch." >&2
fi

if [[ -n "${FLATPAK_ARCH}" ]]; then
  "${SCRIPT_DIR}/package_linux_flatpak.sh" \
    "${BUNDLE_DIR}" \
    "${OUTPUT_DIR}/斛生-linux-${PACKAGE_LABEL}.flatpak" \
    "${VERSION}" \
    "${FLATPAK_ARCH}"
else
  echo "Skip Flatpak for ${ARCH_PROFILE}: this script only packages prebuilt bundles for supported Flatpak runtimes." >&2
fi
