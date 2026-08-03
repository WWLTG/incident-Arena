#!/usr/bin/env bash
set -euo pipefail

kubectl delete namespace incident-arena-06 \
  --ignore-not-found
