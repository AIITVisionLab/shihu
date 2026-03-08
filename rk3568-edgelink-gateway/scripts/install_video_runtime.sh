#!/usr/bin/env bash
set -euo pipefail

# 说明：
# - 默认安装 go2rtc 和 frp 的 latest 版本。
# - 如需固定版本，可在运行前导出 GO2RTC_VERSION / FRP_VERSION。
# - 该脚本只负责把二进制安装到 /usr/local/bin。

GO2RTC_VERSION="${GO2RTC_VERSION:-latest}"
FRP_VERSION="${FRP_VERSION:-latest}"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "missing command: $1" >&2
    exit 1
  }
}

need_cmd curl
need_cmd python3
need_cmd tar
need_cmd sudo
need_cmd install

fetch_release_json() {
  local repo="$1"
  local version="$2"
  if [ "$version" = "latest" ]; then
    curl -fsSL "https://api.github.com/repos/${repo}/releases/latest"
  else
    curl -fsSL "https://api.github.com/repos/${repo}/releases/tags/${version}"
  fi
}

pick_asset_url() {
  local pattern="$1"
  python3 -c 'import json,sys; data=json.load(sys.stdin); pat=sys.argv[1];
for asset in data.get("assets", []):
    url = asset.get("browser_download_url", "")
    name = asset.get("name", "")
    if pat in name:
        print(url)
        raise SystemExit(0)
raise SystemExit("asset not found: %s" % pat)' "$pattern"
}

GO2RTC_JSON="$TMP_DIR/go2rtc_release.json"
FRP_JSON="$TMP_DIR/frp_release.json"
fetch_release_json "AlexxIT/go2rtc" "$GO2RTC_VERSION" > "$GO2RTC_JSON"
fetch_release_json "fatedier/frp" "$FRP_VERSION" > "$FRP_JSON"

GO2RTC_URL="$(pick_asset_url "linux_arm64" < "$GO2RTC_JSON")"
FRP_URL="$(pick_asset_url "linux_arm64.tar.gz" < "$FRP_JSON")"

curl -fL "$GO2RTC_URL" -o "$TMP_DIR/go2rtc"
chmod +x "$TMP_DIR/go2rtc"
sudo install -m 0755 "$TMP_DIR/go2rtc" /usr/local/bin/go2rtc

curl -fL "$FRP_URL" -o "$TMP_DIR/frp.tar.gz"
tar -xzf "$TMP_DIR/frp.tar.gz" -C "$TMP_DIR"
FRP_DIR="$(find "$TMP_DIR" -maxdepth 1 -type d -name 'frp_*_linux_arm64' | head -n 1)"
[ -n "$FRP_DIR" ] || { echo "未找到 frp 解压目录" >&2; exit 1; }
sudo install -m 0755 "$FRP_DIR/frpc" /usr/local/bin/frpc

/usr/local/bin/go2rtc -version || true
/usr/local/bin/frpc -v || true
