#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="incident-arena-08"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
MANIFEST_DIR="${LAB_DIR}/manifests"

echo "===== Reset namespace ====="
kubectl delete namespace "${NAMESPACE}" --ignore-not-found=true --wait=true

echo
echo "===== Apply Incident Arena 08 ====="
kubectl apply -f "${MANIFEST_DIR}/00-namespace.yaml"
kubectl apply -f "${MANIFEST_DIR}/01-limitrange.yaml"
kubectl apply -f "${MANIFEST_DIR}/02-configmap.yaml"
kubectl apply -f "${MANIFEST_DIR}/03-deployment.yaml"
kubectl apply -f "${MANIFEST_DIR}/04-service.yaml"
kubectl apply -f "${MANIFEST_DIR}/05-client.yaml"

echo
echo "===== Lab applied ====="
echo "Run:"
echo "  ./scripts/baseline-tests.sh"
