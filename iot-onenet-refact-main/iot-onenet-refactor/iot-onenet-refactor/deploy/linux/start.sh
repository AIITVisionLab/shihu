#!/usr/bin/env bash
set -euo pipefail

APP_HOME="${APP_HOME:-/opt/iot-onenet}"
CONF_HOME="${CONF_HOME:-/etc/iot-onenet}"
JAR_PATH="${JAR_PATH:-${APP_HOME}/app.jar}"
CONFIG_FILE="${CONFIG_FILE:-${CONF_HOME}/application-prod.yml}"
SPRING_PROFILE="${SPRING_PROFILE:-prod}"
JAVA_BIN="${JAVA_BIN:-java}"
JAVA_OPTS="${JAVA_OPTS:-}"

if [[ ! -f "${JAR_PATH}" ]]; then
  echo "Jar not found: ${JAR_PATH}" >&2
  exit 1
fi

if [[ ! -f "${CONFIG_FILE}" ]]; then
  echo "Config not found: ${CONFIG_FILE}" >&2
  exit 1
fi

java_opts=()
if [[ -n "${JAVA_OPTS}" ]]; then
  read -r -a java_opts <<< "${JAVA_OPTS}"
fi

exec "${JAVA_BIN}" \
  "${java_opts[@]}" \
  -jar "${JAR_PATH}" \
  --spring.profiles.active="${SPRING_PROFILE}" \
  --spring.config.additional-location="file:${CONFIG_FILE}"
