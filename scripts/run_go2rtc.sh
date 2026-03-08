#!/usr/bin/env bash
set -euo pipefail
cd /home/linaro/project/EdgeLink_RK3568
exec /usr/local/bin/go2rtc -config /home/linaro/project/EdgeLink_RK3568/config/go2rtc.yaml
