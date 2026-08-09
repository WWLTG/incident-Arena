#!/usr/bin/env bash
set -u

LAB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$LAB_DIR/manifests/00-namespace.yaml"
kubectl apply -f "$LAB_DIR/manifests/01-secret.yaml"
kubectl apply -f "$LAB_DIR/manifests/02-pvc.yaml"
kubectl apply -f "$LAB_DIR/manifests/03-deployment.yaml"
kubectl apply -f "$LAB_DIR/manifests/04-service.yaml"
kubectl apply -f "$LAB_DIR/manifests/05-client.yaml"

echo
echo "Incident Arena 09 applied."
echo "Run: ./scripts/baseline-tests.sh"
