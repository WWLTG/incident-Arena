#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "===== Apply Incident Arena 11 ====="

for manifest in \
  00-namespace.yaml \
  01-headless-service.yaml \
  02-statefulset.yaml \
  03-client.yaml
do
  kubectl apply -f "$ROOT_DIR/manifests/$manifest"
done

echo
echo "Lab applied."
echo "Run: ./scripts/baseline-tests.sh"
