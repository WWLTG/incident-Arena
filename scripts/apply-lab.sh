#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
LAB_DIR=$(cd -- "$SCRIPT_DIR/.." && pwd)
NAMESPACE=incident-arena-02

kubectl apply -f "$LAB_DIR/manifests"
kubectl wait --for=condition=Ready pod/arena-client \
  -n "$NAMESPACE" \
  --timeout=90s

echo
echo "Lab applied. Run: ./scripts/baseline-tests.sh"
