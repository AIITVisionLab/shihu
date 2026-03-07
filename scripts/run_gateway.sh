#!/usr/bin/env bash
set -euo pipefail
cd /home/linaro/project/EdgeLink_RK3568
exec /usr/bin/python3 src/edgelink_gateway.py --config config/edgelink.ini
