#!/usr/bin/env bash
set -euo pipefail

PACKAGE_DIR="${1:-package}"
RELEASE_TAG="${2:-未标记}"
PACKAGE_LABEL="$(basename "${PACKAGE_DIR}")"

if [[ ! -d "${PACKAGE_DIR}" ]]; then
  echo "Package directory not found: ${PACKAGE_DIR}" >&2
  exit 1
fi

mapfile -t files < <(
  find "${PACKAGE_DIR}" -maxdepth 1 -type f \
    ! -name 'README.txt' \
    ! -name 'SHA256SUMS' \
    -printf '%f\n' | sort
)

if [[ "${#files[@]}" -eq 0 ]]; then
  echo "No release files found in ${PACKAGE_DIR}" >&2
  exit 1
fi

(
  cd "${PACKAGE_DIR}"
  sha256sum "${files[@]}" > SHA256SUMS
)

generated_at="$(TZ=Asia/Shanghai date '+%Y-%m-%d %H:%M:%S %Z')"

{
  echo "斛生 当前可用安装包说明"
  echo
  echo "整理时间：${generated_at}"
  echo "目录：${PACKAGE_LABEL}"
  echo "版本标签：${RELEASE_TAG}"
  echo
  echo "当前目录包含："
  for file in "${files[@]}"; do
    echo "- ${file}"
  done
  echo "- SHA256SUMS"
  echo
  echo "来源说明："
  echo "- Android 提供 APK 与 AAB 两种发布产物。"
  echo "- Linux、Windows、macOS、Web 产物均为发布目录重新压缩后的分发包。"
  echo "- iOS 产物为未签名 Runner.app 压缩包，需要自行签名后再安装或导出。"
  echo "- OpenHarmony / 鸿蒙 产物仅在启用专用自托管 runner 时生成。"
  echo
  echo "校验说明："
  echo "- SHA256SUMS 记录了当前目录下各包的 sha256 校验值，可直接用于分发前核对。"
} > "${PACKAGE_DIR}/README.txt"
