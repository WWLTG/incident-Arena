#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MANIFEST_DIR="$SCRIPT_DIR/../manifests"

echo "Applying Incident Arena 12 manifests..."
kubectl apply -f "$MANIFEST_DIR/00-namespace.yaml"
kubectl apply -f "$MANIFEST_DIR/01-configmap.yaml"
kubectl apply -f "$MANIFEST_DIR/02-rbac.yaml"
kubectl apply -f "$MANIFEST_DIR/03-deployment.yaml"
kubectl apply -f "$MANIFEST_DIR/04-service.yaml"
kubectl apply -f "$MANIFEST_DIR/05-ingress.yaml"

echo ""
echo "Lab applied. Wait a few seconds, then run scripts/baseline-tests.sh"
