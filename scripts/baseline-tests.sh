#!/usr/bin/env bash
set -euo pipefail

NAMESPACE=incident-arena-02
SERVICE=arena-api-service
CLIENT=arena-client

echo "Deployment and Pod status"
kubectl get deployment/arena-api -n "$NAMESPACE"
kubectl get pods -n "$NAMESPACE" -o wide

echo
echo "Service and EndpointSlice status"
kubectl get service/"$SERVICE" -n "$NAMESPACE"
kubectl get endpointslice \
  -n "$NAMESPACE" \
  -l kubernetes.io/service-name="$SERVICE"

echo
echo "Client request"
set +e
REQUEST_OUTPUT=$(kubectl exec -n "$NAMESPACE" "$CLIENT" -- \
  wget -qO- -T 3 "http://$SERVICE" 2>&1)
REQUEST_EXIT_CODE=$?
set -e

printf '%s\n' "$REQUEST_OUTPUT"
echo "request_exit_code=$REQUEST_EXIT_CODE"
