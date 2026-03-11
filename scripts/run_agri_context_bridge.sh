#!/usr/bin/env bash
set -euo pipefail

cd /home/linaro/project/EdgeLink_RK3568
exec /usr/bin/python3 src/agri_context_bridge.py --config config/agri-context-bridge.ini
