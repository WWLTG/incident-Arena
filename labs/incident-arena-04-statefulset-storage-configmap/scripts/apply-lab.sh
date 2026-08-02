#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
NAMESPACE=incident-arena-04

command -v kubectl >/dev/null 2>&1 || {
  echo "kubectl was not found. Run this lab inside the Kubernetes toolbox." >&2
  exit 1
}

context=$(kubectl config current-context)
echo "Current context: $context"

kubectl apply -f "$ROOT_DIR/manifests/00-namespace.yaml"
kubectl apply -f "$ROOT_DIR/manifests/01-storage.yaml"
kubectl apply -f "$ROOT_DIR/manifests/02-configmap.yaml"
kubectl apply -f "$ROOT_DIR/manifests/03-statefulset.yaml"
kubectl apply -f "$ROOT_DIR/manifests/04-headless-service.yaml"
kubectl apply -f "$ROOT_DIR/manifests/05-client.yaml"

kubectl wait \
  --for=condition=Ready \
  pod/arena-client \
  -n "$NAMESPACE" \
  --timeout=90s

echo
echo "Broken lab applied."
echo "Run: ./scripts/baseline-tests.sh"
