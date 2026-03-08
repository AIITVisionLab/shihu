#!/usr/bin/env bash
set -euo pipefail
cd /home/linaro/project/EdgeLink_RK3568
exec /usr/local/bin/frpc -c /home/linaro/project/EdgeLink_RK3568/config/frpc.toml
