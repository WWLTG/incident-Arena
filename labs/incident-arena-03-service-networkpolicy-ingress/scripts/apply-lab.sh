#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$ROOT_DIR/manifests/00-namespaces.yaml"
kubectl apply -f "$ROOT_DIR/manifests/01-configmap.yaml"
kubectl apply -f "$ROOT_DIR/manifests/02-deployment.yaml"
kubectl apply -f "$ROOT_DIR/manifests/03-service.yaml"
kubectl apply -f "$ROOT_DIR/manifests/04-networkpolicy.yaml"
kubectl apply -f "$ROOT_DIR/manifests/05-ingress.yaml"
kubectl apply -f "$ROOT_DIR/manifests/06-client.yaml"

echo
printf '%s\n' 'Waiting for the application Deployment...'
kubectl rollout status deployment/arena-api \
  -n incident-arena-03-app \
  --timeout=120s

echo
printf '%s\n' 'Waiting for the client Pod...'
kubectl wait pod/arena-client \
  -n incident-arena-03-client \
  --for=condition=Ready \
  --timeout=120s

echo
printf '%s\n' 'Incident Arena 03 applied in its broken state.'
printf '%s\n' 'Run ./scripts/baseline-tests.sh'
