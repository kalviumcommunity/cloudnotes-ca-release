#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
[ ! -e .lab/prepared ] || { echo 'SETUP FAILED: already prepared; do not rerun during tasks.' >&2; exit 1; }
bash scripts/prerequisites.sh
# Dedicated owned registry. Never remove/adopt an existing named container.
if docker container inspect cloudnotes-ca-registry >/dev/null 2>&1; then
  echo 'SETUP FAILED: cloudnotes-ca-registry exists; inspect and clean up only your own previous lab.' >&2
  exit 1
fi
docker run -d --label cloud.lab=cloudnotes-ca-release --name cloudnotes-ca-registry -p 127.0.0.1:5001:5000 registry:2
bash scripts/preflight.sh
touch .lab/prepared
echo 'SETUP READY: provider initialized, caches rehearsed, registry running. Broken configuration remains unchanged.'
