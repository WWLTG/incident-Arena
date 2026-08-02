#!/usr/bin/env bash
set -u

NAMESPACE=incident-arena-04

section() {
  printf '\n===== %s =====\n' "$1"
}

section "Storage"
kubectl get storageclass incident-arena-04-local
kubectl get pvc -n "$NAMESPACE" -o wide

section "Workload"
kubectl get statefulset,pod -n "$NAMESPACE" -o wide

section "Service discovery"
kubectl get service,endpointslice -n "$NAMESPACE" -o wide

section "Stateful Pod details"
kubectl describe pod arena-store-0 -n "$NAMESPACE" 2>/dev/null || true

section "Namespace events"
kubectl get events -n "$NAMESPACE" \
  --sort-by=.metadata.creationTimestamp || true

section "Client DNS test"
kubectl exec arena-client -n "$NAMESPACE" -- \
  nslookup arena-store 2>&1 || true

section "Stable Pod DNS test"
kubectl exec arena-client -n "$NAMESPACE" -- \
  nslookup arena-store-0.arena-store 2>&1 || true

section "Client HTTP test"
kubectl exec arena-client -n "$NAMESPACE" -- \
  wget -qO- -T 3 http://arena-store 2>&1 || true

printf '\nBaseline tests completed. Expected failures are preserved for investigation.\n'
