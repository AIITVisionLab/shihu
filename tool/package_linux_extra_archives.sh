#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/package_linux_common.sh"

BUNDLE_DIR="${1:?bundle dir required}"
OUTPUT_DIR_INPUT="${2:?output dir required}"
ARCH_PROFILE="${3:?arch profile required}"

case "${ARCH_PROFILE}" in
  x64)
    PACKAGE_LABEL="x64"
    ;;
  arm64)
    PACKAGE_LABEL="arm64"
    ;;
  loong64|loongarch64)
    PACKAGE_LABEL="loong64"
    ;;
  riscv64)
    PACKAGE_LABEL="riscv64"
    ;;
  *)
    echo "Unsupported arch profile: ${ARCH_PROFILE}" >&2
    echo "Supported profiles: x64, arm64, loong64, riscv64" >&2
    exit 1
    ;;
esac

package_linux_validate_inputs "${BUNDLE_DIR}"

mkdir -p "${OUTPUT_DIR_INPUT}"
OUTPUT_DIR="$(cd "${OUTPUT_DIR_INPUT}" && pwd)"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

BUNDLE_STAGE_PARENT="${TMP_DIR}/bundle-stage"
PORTABLE_STAGE_PARENT="${TMP_DIR}/portable-stage"
BUNDLE_PACKAGE_DIR="husheng-linux-${PACKAGE_LABEL}-bundle"
PORTABLE_PACKAGE_DIR="husheng-linux-${PACKAGE_LABEL}-portable"
BUNDLE_STAGE_DIR="${BUNDLE_STAGE_PARENT}/${BUNDLE_PACKAGE_DIR}"
PORTABLE_STAGE_DIR="${PORTABLE_STAGE_PARENT}/${PORTABLE_PACKAGE_DIR}"

package_linux_copy_bundle "${BUNDLE_DIR}" "${BUNDLE_STAGE_DIR}"
package_linux_copy_bundle "${BUNDLE_DIR}" "${PORTABLE_STAGE_DIR}"
package_linux_try_fix_rpath "${BUNDLE_STAGE_DIR}" || true
package_linux_try_fix_rpath "${PORTABLE_STAGE_DIR}" || true

cat > "${PORTABLE_STAGE_DIR}/run.sh" <<'EOF'
#!/usr/bin/env sh
set -eu

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
export LD_LIBRARY_PATH="${SCRIPT_DIR}/lib${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"
exec "${SCRIPT_DIR}/husheng" "$@"
EOF
chmod 755 "${PORTABLE_STAGE_DIR}/run.sh"

cat > "${PORTABLE_STAGE_DIR}/README.txt" <<'EOF'
斛生 Linux 便携包

使用方式：
1. 解压当前压缩包。
2. 进入解压后的目录。
3. 执行 ./run.sh。

说明：
- run.sh 会自动补齐 LD_LIBRARY_PATH，优先加载当前目录内的 lib。
- 适合没有 root 权限或不想走系统包管理器的 Linux 环境。
EOF

tar -C "${BUNDLE_STAGE_PARENT}" -czf \
  "${OUTPUT_DIR}/斛生-linux-${PACKAGE_LABEL}-bundle.tar.gz" \
  "${BUNDLE_PACKAGE_DIR}"
tar -C "${BUNDLE_STAGE_PARENT}" -cJf \
  "${OUTPUT_DIR}/斛生-linux-${PACKAGE_LABEL}-bundle.tar.xz" \
  "${BUNDLE_PACKAGE_DIR}"
(
  cd "${BUNDLE_STAGE_PARENT}"
  zip -qr "${OUTPUT_DIR}/斛生-linux-${PACKAGE_LABEL}-bundle.zip" "${BUNDLE_PACKAGE_DIR}"
)

tar -C "${PORTABLE_STAGE_PARENT}" -cJf \
  "${OUTPUT_DIR}/斛生-linux-${PACKAGE_LABEL}-portable.tar.xz" \
  "${PORTABLE_PACKAGE_DIR}"
(
  cd "${PORTABLE_STAGE_PARENT}"
  zip -qr "${OUTPUT_DIR}/斛生-linux-${PACKAGE_LABEL}-portable.zip" "${PORTABLE_PACKAGE_DIR}"
)

if [[ -f "${BUNDLE_DIR}/husheng" ]]; then
  cp "${BUNDLE_DIR}/husheng" "${OUTPUT_DIR}/斛生-linux-${PACKAGE_LABEL}-runner"
fi
