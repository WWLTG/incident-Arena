#!/usr/bin/env bash
set -u

NS="incident-arena-09"

echo "===== Workload status ====="
kubectl get deployment,pod -n "$NS" -o wide || true

echo
echo "===== Storage status ====="
kubectl get pvc -n "$NS" || true

echo
echo "===== Service status ====="
kubectl get service,endpointslice -n "$NS" || true

echo
echo "===== Recent events ====="
kubectl get events -n "$NS" --sort-by=.lastTimestamp | tail -n 20 || true

echo
echo "===== Client request ====="
kubectl exec -n "$NS" arena-client -- \
  curl -sS --max-time 3 http://arena-web-service || true

echo
echo
echo "Baseline complete. Investigate the first blocking failure."
