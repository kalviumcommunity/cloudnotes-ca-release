#!/usr/bin/env bash
set -e

fail() {
  printf 'PREPARATION ERROR: %s\n' "$1" >&2
  exit 1
}

for tool in terraform docker git curl; do
  command -v "$tool" >/dev/null 2>&1 || fail "Missing tool: $tool"
done
terraform_version=$(terraform version) || fail 'Terraform version check failed'
printf '%s\n' "$terraform_version"
if [[ ! "$terraform_version" =~ Terraform\ v1\.([0-9]+)\. ]] || (( BASH_REMATCH[1] < 5 )); then
  fail 'Terraform must be >= 1.5.0 and < 2.0.0'
fi
git --version
curl --version
docker --version
docker info >/dev/null 2>&1 || fail 'Docker engine unavailable; instructor must start/configure it'
docker compose version || fail 'Docker Compose unavailable'
curl --fail --silent --show-error --connect-timeout 3 --max-time 5 \
  http://localhost:5001/v2/ >/dev/null || fail 'Prepared registry unreachable at http://localhost:5001/v2/'
printf 'READY: tools, Docker engine, Compose and local registry reachable\n'
