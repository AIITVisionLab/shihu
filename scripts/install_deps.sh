#!/usr/bin/env bash
set -euo pipefail
if ! sudo apt-get update; then
  echo '[warn] apt-get update failed, fallback to current package cache' >&2
fi
sudo apt-get install -y python3-paho-mqtt
/usr/bin/python3 -c 'import paho.mqtt.client; print("python3-paho-mqtt ready")'
