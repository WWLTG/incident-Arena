#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NAMESPACE="incident-arena-05"

printf '\n===== Apply Incident Arena 05 =====\n'
kubectl apply -f "$ROOT_DIR/manifests/00-namespace.yaml"
kubectl apply -f "$ROOT_DIR/manifests/01-configmap.yaml"
kubectl apply -f "$ROOT_DIR/manifests/02-serviceaccount.yaml"
kubectl apply -f "$ROOT_DIR/manifests/03-role.yaml"
kubectl apply -f "$ROOT_DIR/manifests/04-rolebinding.yaml"
kubectl apply -f "$ROOT_DIR/manifests/05-cronjob.yaml"

kubectl delete job arena-report-manual \
  -n "$NAMESPACE" \
  --ignore-not-found=true \
  --wait=true >/dev/null

printf '\n===== Lab resources =====\n'
kubectl get cronjob,serviceaccount,role,rolebinding,configmap \
  -n "$NAMESPACE"

printf '\nLab applied. Run ./scripts/baseline-tests.sh\n'
