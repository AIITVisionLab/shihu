#!/usr/bin/env bash
set -euo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  echo "Please run as root." >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

APP_NAME="${APP_NAME:-iot-onenet}"
APP_USER="${APP_USER:-iot-onenet}"
APP_GROUP="${APP_GROUP:-${APP_USER}}"
APP_HOME="${APP_HOME:-/opt/iot-onenet}"
CONF_HOME="${CONF_HOME:-/etc/iot-onenet}"
LOG_HOME="${LOG_HOME:-/var/log/iot-onenet}"
SERVICE_NAME="${SERVICE_NAME:-iot-onenet}"

if [[ -n "${JAR_SOURCE:-}" ]]; then
  jar_source="${JAR_SOURCE}"
else
  jar_source="$(find "${REPO_ROOT}/target" -maxdepth 1 -type f -name "*.jar" ! -name "*.jar.original" | head -n 1 || true)"
fi

if [[ -z "${jar_source}" || ! -f "${jar_source}" ]]; then
  echo "Build jar not found. Run 'mvn clean package -DskipTests' first." >&2
  exit 1
fi

if ! getent group "${APP_GROUP}" >/dev/null 2>&1; then
  groupadd --system "${APP_GROUP}"
fi

if ! id -u "${APP_USER}" >/dev/null 2>&1; then
  useradd --system --gid "${APP_GROUP}" --home "${APP_HOME}" --shell /usr/sbin/nologin "${APP_USER}"
fi

install -d -m 0755 "${APP_HOME}" "${APP_HOME}/bin" "${CONF_HOME}" "${LOG_HOME}"
install -m 0644 "${jar_source}" "${APP_HOME}/app.jar"
install -m 0755 "${SCRIPT_DIR}/start.sh" "${APP_HOME}/bin/start.sh"

if [[ ! -f "${CONF_HOME}/application-prod.yml" ]]; then
  install -m 0640 "${SCRIPT_DIR}/application-prod.yml" "${CONF_HOME}/application-prod.yml"
fi

if [[ ! -f "${CONF_HOME}/iot-onenet.env" ]]; then
  install -m 0640 "${SCRIPT_DIR}/iot-onenet.env.example" "${CONF_HOME}/iot-onenet.env"
fi

service_target="/etc/systemd/system/${SERVICE_NAME}.service"
sed \
  -e "s|__APP_USER__|${APP_USER}|g" \
  -e "s|__APP_GROUP__|${APP_GROUP}|g" \
  -e "s|__APP_HOME__|${APP_HOME}|g" \
  -e "s|__CONF_HOME__|${CONF_HOME}|g" \
  "${SCRIPT_DIR}/iot-onenet.service" > "${service_target}"
chmod 0644 "${service_target}"

chown -R "${APP_USER}:${APP_GROUP}" "${APP_HOME}" "${LOG_HOME}"
chown root:"${APP_GROUP}" "${CONF_HOME}" "${CONF_HOME}/application-prod.yml" "${CONF_HOME}/iot-onenet.env"
chmod 0750 "${CONF_HOME}"
chmod 0640 "${CONF_HOME}/application-prod.yml" "${CONF_HOME}/iot-onenet.env"

systemctl daemon-reload
systemctl enable "${SERVICE_NAME}"

echo "Installed ${APP_NAME}."
echo "Edit ${CONF_HOME}/iot-onenet.env and start with: systemctl start ${SERVICE_NAME}"
echo "Check status with: systemctl status ${SERVICE_NAME}"
