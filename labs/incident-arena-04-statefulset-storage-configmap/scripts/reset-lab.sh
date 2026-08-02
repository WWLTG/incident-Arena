#!/usr/bin/env bash
set -euo pipefail

kubectl delete namespace incident-arena-04 \
  --ignore-not-found \
  --wait=true

kubectl delete storageclass incident-arena-04-local \
  --ignore-not-found

echo "Incident Arena 04 resources removed."
