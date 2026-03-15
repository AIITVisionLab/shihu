#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="/home/linaro/project/EdgeLink_RK3568"

if ! sudo apt-get update; then
  echo '[warn] apt-get update failed, fallback to current package cache' >&2
fi

sudo apt-get install -y python3-pip
/usr/bin/python3 -m pip install --upgrade pip
/usr/bin/python3 -m pip install -r "${REPO_DIR}/requirements-agri-vector.txt"

/usr/bin/python3 - <<'PY'
import sentence_transformers

print(f"sentence-transformers package ready: {sentence_transformers.__version__}")

try:
    import chromadb
except Exception as exc:
    print(f"[warn] chromadb import failed, runtime will fallback to simple backend: {exc}")
else:
    print("chromadb ready")
PY
