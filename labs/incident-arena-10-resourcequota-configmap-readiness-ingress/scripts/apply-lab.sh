#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "===== Apply Incident Arena 10 ====="

for manifest in \
  00-namespace.yaml \
  01-resourcequota.yaml \
  02-configmap.yaml \
  03-deployment.yaml \
  04-service.yaml \
  05-ingress.yaml \
  06-client.yaml
do
  kubectl apply -f "$ROOT_DIR/manifests/$manifest"
done

echo
echo "Lab applied."
echo "Run: ./scripts/baseline-tests.sh"
