#!/usr/bin/env bash
set -euo pipefail

kubectl delete namespace incident-arena-03-client \
  --ignore-not-found

kubectl delete namespace incident-arena-03-app \
  --ignore-not-found
