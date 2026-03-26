#!/usr/bin/env bash
set -euo pipefail

PACKAGE_NAME="husheng"
APP_NAME="斛生"
APP_COMMENT="斛生跨平台客户端"
APP_KEYWORDS="斛生;石斛;监控;"
PACKAGE_URL="https://github.com/AIITVisionLab/shihu"
INSTALL_ROOT="/opt/${PACKAGE_NAME}"

package_linux_root_dir() {
  cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd
}

package_linux_icon_source() {
  printf '%s/assets/branding/app_icon.png\n' "$(package_linux_root_dir)"
}

package_linux_validate_inputs() {
  local bundle_dir="$1"
  local icon_source
  icon_source="$(package_linux_icon_source)"

  if [[ ! -d "${bundle_dir}" ]]; then
    echo "Bundle directory not found: ${bundle_dir}" >&2
    exit 1
  fi

  if [[ ! -f "${icon_source}" ]]; then
    echo "Icon not found: ${icon_source}" >&2
    exit 1
  fi
}

package_linux_copy_bundle() {
  local bundle_dir="$1"
  local target_dir="$2"

  mkdir -p "${target_dir}"
  cp -R "${bundle_dir}/." "${target_dir}/"
}

package_linux_copy_icon() {
  local target_file="$1"

  mkdir -p "$(dirname "${target_file}")"
  cp "$(package_linux_icon_source)" "${target_file}"
}

package_linux_write_launcher() {
  local target_file="$1"
  local app_root="$2"

  cat > "${target_file}" <<EOF
#!/bin/sh
APP_ROOT="${app_root}"
export LD_LIBRARY_PATH="\${APP_ROOT}/lib\${LD_LIBRARY_PATH:+:\${LD_LIBRARY_PATH}}"
exec "\${APP_ROOT}/husheng" "\$@"
EOF
  chmod 755 "${target_file}"
}

package_linux_write_desktop_file() {
  local target_file="$1"
  local exec_command="$2"
  local icon_name="${3:-${PACKAGE_NAME}}"

  cat > "${target_file}" <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=${APP_NAME}
Comment=${APP_COMMENT}
Exec=${exec_command}
Icon=${icon_name}
Terminal=false
Categories=Utility;
Keywords=${APP_KEYWORDS}
EOF
}

package_linux_try_fix_rpath() {
  local app_root="$1"
  local elf_path

  if ! command -v patchelf >/dev/null 2>&1; then
    return 1
  fi

  while IFS= read -r elf_path; do
    if readelf -d "${elf_path}" 2>/dev/null | grep -Eq '(RPATH|RUNPATH)'; then
      patchelf --set-rpath '$ORIGIN' "${elf_path}"
    fi
  done < <(find "${app_root}" -type f \( -name '*.so' -o -name '*.so.*' -o -name 'husheng' \))
}
