#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/package_linux_common.sh"

BUNDLE_DIR="${1:?bundle dir required}"
OUTPUT_FILE="${2:?output file required}"
VERSION="${3:?version required}"
RPM_ARCH="${4:?rpm arch required}"

package_linux_validate_inputs "${BUNDLE_DIR}"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

TOPDIR="${TMP_DIR}/rpmbuild"
BUILDROOT_DIR="${TMP_DIR}/buildroot"
mkdir -p \
  "${TOPDIR}/BUILD" \
  "${TOPDIR}/BUILDROOT" \
  "${TOPDIR}/RPMS" \
  "${TOPDIR}/SOURCES" \
  "${TOPDIR}/SPECS" \
  "${TOPDIR}/SRPMS" \
  "${BUILDROOT_DIR}${INSTALL_ROOT}" \
  "${BUILDROOT_DIR}/usr/bin" \
  "${BUILDROOT_DIR}/usr/share/applications" \
  "${BUILDROOT_DIR}/usr/share/icons/hicolor/256x256/apps"

package_linux_copy_bundle "${BUNDLE_DIR}" "${BUILDROOT_DIR}${INSTALL_ROOT}"
package_linux_copy_icon "${BUILDROOT_DIR}/usr/share/icons/hicolor/256x256/apps/${PACKAGE_NAME}.png"
package_linux_write_launcher "${BUILDROOT_DIR}/usr/bin/${PACKAGE_NAME}" "${INSTALL_ROOT}"
package_linux_write_desktop_file \
  "${BUILDROOT_DIR}/usr/share/applications/${PACKAGE_NAME}.desktop" \
  "${PACKAGE_NAME}" \
  "${PACKAGE_NAME}"

RPATH_FIXED=0
if package_linux_try_fix_rpath "${BUILDROOT_DIR}${INSTALL_ROOT}"; then
  RPATH_FIXED=1
fi

SPEC_FILE="${TOPDIR}/SPECS/${PACKAGE_NAME}.spec"
cat > "${SPEC_FILE}" <<EOF
%global debug_package %{nil}

Name: ${PACKAGE_NAME}
Version: ${VERSION}
Release: 1%{?dist}
Summary: 斛生跨平台客户端
License: Proprietary
URL: https://github.com/AIITVisionLab/shihu
BuildArch: ${RPM_ARCH}

%description
斛生跨平台客户端。

%install
mkdir -p "%{buildroot}"
cp -a "${BUILDROOT_DIR}/." "%{buildroot}/"

%files
%defattr(-,root,root,-)
${INSTALL_ROOT}
/usr/bin/${PACKAGE_NAME}
/usr/share/applications/${PACKAGE_NAME}.desktop
/usr/share/icons/hicolor/256x256/apps/${PACKAGE_NAME}.png

%changelog
* $(LC_ALL=C date '+%a %b %d %Y') AIITVisionLab <noreply@example.com> - ${VERSION}-1
- 打包 Linux RPM 安装包
EOF

mkdir -p "$(dirname "${OUTPUT_FILE}")"
if [[ "${RPATH_FIXED}" == "1" ]]; then
  rpmbuild --define "_topdir ${TOPDIR}" -bb "${SPEC_FILE}"
else
  QA_RPATHS=$((0x0002)) rpmbuild --define "_topdir ${TOPDIR}" -bb "${SPEC_FILE}"
fi

RPM_OUTPUT="$(find "${TOPDIR}/RPMS" -type f -name '*.rpm' | head -n 1)"
if [[ -z "${RPM_OUTPUT}" ]]; then
  echo "RPM package not generated." >&2
  exit 1
fi

cp "${RPM_OUTPUT}" "${OUTPUT_FILE}"
