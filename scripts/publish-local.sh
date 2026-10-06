#!/usr/bin/env bash
set -e

image=cloudnotes:1.0.0
registry_image=localhost:5001/cloudnotes:1.0.0

docker build --progress=plain -t "$image" .
docker tag "$image" "$registry_image"
docker push "$registry_image"
docker pull "$registry_image"
digest=$(docker image inspect "$registry_image" --format '{{range .RepoDigests}}{{println .}}{{end}}')
registry_digest=''
while IFS= read -r candidate; do
  case "$candidate" in
    localhost:5001/cloudnotes@sha256:*) registry_digest="$candidate"; break ;;
  esac
done <<< "$digest"
if [ -z "$registry_digest" ]; then
  printf 'ERROR: pulled image has no local registry RepoDigest\n' >&2
  exit 1
fi
docker tag "$registry_image" "$image"
printf 'BUILD: %s\n' "$image"
printf 'PUSH/PULL: %s (registry round-trip; pull may use cache)\n' "$registry_image"
printf 'DIGEST: %s\n' "$registry_digest"
printf 'COMPOSE IMAGE: %s\n' "$image"
