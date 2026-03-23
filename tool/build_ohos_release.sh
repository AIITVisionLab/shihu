#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
OUTPUT_FILE="${1:-${REPO_ROOT}/bag/斛生-ohos-arm64.hap}"

LOCAL_PROPERTIES="${REPO_ROOT}/ohos/local.properties"
if [[ ! -f "${LOCAL_PROPERTIES}" ]]; then
  echo "未找到 OHOS 本地配置: ${LOCAL_PROPERTIES}" >&2
  exit 1
fi

FLUTTER_OHOS_HOME="$(sed -n 's#^flutter.sdk=##p' "${LOCAL_PROPERTIES}")"
OHOS_SDK_HOME="$(sed -n 's#^hwsdk.dir=##p' "${LOCAL_PROPERTIES}")"

if [[ -z "${FLUTTER_OHOS_HOME}" || ! -x "${FLUTTER_OHOS_HOME}/bin/flutter" ]]; then
  echo "OHOS Flutter SDK 无效: ${FLUTTER_OHOS_HOME}" >&2
  exit 1
fi

if [[ -z "${OHOS_SDK_HOME}" || ! -d "${OHOS_SDK_HOME}" ]]; then
  echo "HarmonyOS SDK 无效: ${OHOS_SDK_HOME}" >&2
  exit 1
fi

TMP_DIR="$(mktemp -d)"
WORKSPACE_DIR="${TMP_DIR}/workspace"
trap 'rm -rf "${TMP_DIR}"' EXIT

mkdir -p "${WORKSPACE_DIR}"

rsync -a \
  --exclude '.git' \
  --exclude '.dart_tool' \
  --exclude 'build' \
  --exclude 'bag' \
  --exclude 'flutter_*.log' \
  --exclude 'ohos/node_modules' \
  --exclude 'ohos/.hvigor' \
  "${REPO_ROOT}/" "${WORKSPACE_DIR}/"

PUBSPEC_PATH="${WORKSPACE_DIR}/pubspec.yaml"
PUBSPEC_TMP="${WORKSPACE_DIR}/pubspec.ohos.tmp.yaml"

# OHOS Flutter 3.35.x 仍基于 Dart 3.9，当前仓库的部分开发依赖和较新的
# Darwin 平台插件会导致 pub 解析或编译失败。这里在临时工作区裁掉 dev 依赖，
# 并固定到与 Dart 3.9 兼容的运行时版本，不污染主工程。
awk '
  /^dev_dependencies:/ { skipping = 1; next }
  skipping && /^[^[:space:]][^:]*:/ { skipping = 0 }
  !skipping { print }
' "${PUBSPEC_PATH}" > "${PUBSPEC_TMP}"

cat >> "${PUBSPEC_TMP}" <<'EOF'

dependency_overrides:
  path_provider_foundation: 2.5.1
  video_player: 2.10.1
  video_player_avfoundation: 2.8.8
EOF

mv "${PUBSPEC_TMP}" "${PUBSPEC_PATH}"

export PATH="${FLUTTER_OHOS_HOME}/bin:${OHOS_SDK_HOME%/sdk}/tool/node/bin:${OHOS_SDK_HOME%/sdk}/bin:${PATH}"
export FLUTTER_GIT_URL="https://gitcode.com/openharmony-sig/flutter_flutter.git"

pushd "${WORKSPACE_DIR}" >/dev/null
"${FLUTTER_OHOS_HOME}/bin/flutter" pub get
(
  cd ohos
  npm install >/dev/null
)

KEY_EVENT_HANDLER_PATH="$(find "${WORKSPACE_DIR}/ohos/oh_modules/.ohpm" -path '*@ohos/flutter_ohos/src/main/ets/embedding/ohos/KeyEventHandler.ets' | head -n 1)"
if [[ -n "${KEY_EVENT_HANDLER_PATH}" ]]; then
  # API 18 的 KeyEvent 类型里没有 isCapsLockOn / isNumLockOn，当前 flutter_ohos
  # 直接访问会导致 ArkTS 编译失败。这里在临时工作区回退到安全默认值。
  sed -i \
    -e "s/const isCapsLockOn = event.isCapsLockOn !== undefined ? event.isCapsLockOn : false;/const isCapsLockOn = false;/" \
    -e "s/const isNumLockOn = event.isNumLockOn !== undefined ? event.isNumLockOn : false; \\/\\/ Default to true if not available/const isNumLockOn = false;/" \
    "${KEY_EVENT_HANDLER_PATH}"
fi

"${FLUTTER_OHOS_HOME}/bin/flutter" build hap --release

HAP_PATH="$(find build ohos -type f -name '*.hap' | head -n 1)"
if [[ -z "${HAP_PATH}" ]]; then
  echo "未找到 HAP 产物。" >&2
  exit 1
fi
popd >/dev/null

mkdir -p "$(dirname "${OUTPUT_FILE}")"
cp "${WORKSPACE_DIR}/${HAP_PATH}" "${OUTPUT_FILE}"
echo "HAP 已输出到: ${OUTPUT_FILE}"
