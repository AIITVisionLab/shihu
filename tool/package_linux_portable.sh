#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/package_linux_common.sh"

BUNDLE_DIR="${1:?bundle dir required}"
OUTPUT_FILE="${2:?output file required}"
PACKAGE_DIR_NAME="${3:-husheng-linux-portable}"

package_linux_validate_inputs "${BUNDLE_DIR}"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

STAGE_PARENT="${TMP_DIR}/stage"
PACKAGE_ROOT="${STAGE_PARENT}/${PACKAGE_DIR_NAME}"
mkdir -p "${PACKAGE_ROOT}"

package_linux_copy_bundle "${BUNDLE_DIR}" "${PACKAGE_ROOT}"
package_linux_try_fix_rpath "${PACKAGE_ROOT}" || true

cat > "${PACKAGE_ROOT}/run.sh" <<'EOF'
#!/usr/bin/env sh
set -eu

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
export LD_LIBRARY_PATH="${SCRIPT_DIR}/lib${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"
exec "${SCRIPT_DIR}/husheng" "$@"
EOF
chmod 755 "${PACKAGE_ROOT}/run.sh"

cat > "${PACKAGE_ROOT}/README.txt" <<'EOF'
斛生 Linux 便携包

使用方式：
1. 解压当前压缩包。
2. 进入解压后的目录。
3. 执行 ./run.sh。

说明：
- run.sh 会自动补齐 LD_LIBRARY_PATH，优先加载当前目录内的 lib。
- 适合没有 root 权限或不想走系统包管理器的 Linux 环境。
EOF

mkdir -p "$(dirname "${OUTPUT_FILE}")"
tar -C "${STAGE_PARENT}" -czf "${OUTPUT_FILE}" "${PACKAGE_DIR_NAME}"
