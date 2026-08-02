#!/usr/bin/env bash
set -u

NAMESPACE="incident-arena-04"
CLIENT_POD="arena-client"
STATEFUL_POD="arena-store-0"

SERVICE_FQDN="arena-store.${NAMESPACE}.svc.cluster.local"
POD_FQDN="${STATEFUL_POD}.arena-store.${NAMESPACE}.svc.cluster.local"

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
kubectl describe pod "$STATEFUL_POD" \
  -n "$NAMESPACE" 2>/dev/null || true

section "Namespace events"
kubectl get events -n "$NAMESPACE" \
  --sort-by=.metadata.creationTimestamp || true

section "Client DNS test"
kubectl exec "$CLIENT_POD" -n "$NAMESPACE" -- \
  nslookup "$SERVICE_FQDN" 2>&1 || true

section "Stable Pod DNS test"
kubectl exec "$CLIENT_POD" -n "$NAMESPACE" -- \
  nslookup "$POD_FQDN" 2>&1 || true

section "Client HTTP test"
kubectl exec "$CLIENT_POD" -n "$NAMESPACE" -- \
  wget -qO- -T 3 "http://${SERVICE_FQDN}" 2>&1 || true

printf '\nBaseline tests completed. Expected failures are preserved for investigation.\n'
