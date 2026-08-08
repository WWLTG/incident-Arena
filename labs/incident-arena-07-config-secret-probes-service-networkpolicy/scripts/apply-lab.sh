#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$ROOT_DIR/manifests/00-namespaces.yaml"
kubectl apply -f "$ROOT_DIR/manifests/01-config.yaml"
kubectl apply -f "$ROOT_DIR/manifests/02-secret.yaml"
kubectl apply -f "$ROOT_DIR/manifests/03-deployment.yaml"
kubectl apply -f "$ROOT_DIR/manifests/04-service.yaml"
kubectl apply -f "$ROOT_DIR/manifests/05-networkpolicy.yaml"
kubectl apply -f "$ROOT_DIR/manifests/06-client.yaml"

echo
echo "Incident Arena 07 applied."
echo "Run: ./scripts/baseline-tests.sh"
