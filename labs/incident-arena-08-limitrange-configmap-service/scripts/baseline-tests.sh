#!/usr/bin/env bash
set -u

NAMESPACE="incident-arena-08"

echo "===== Workload status ====="
kubectl get deployment,replicaset,pods -n "${NAMESPACE}" -o wide || true

echo
echo "===== Service status ====="
kubectl get svc,endpointslices -n "${NAMESPACE}" || true

echo
echo "===== LimitRange ====="
kubectl get limitrange -n "${NAMESPACE}" || true

echo
echo "===== Recent events ====="
kubectl get events -n "${NAMESPACE}" \
  --sort-by=.metadata.creationTimestamp | tail -n 25 || true

echo
echo "===== Client request ====="
if kubectl wait --for=condition=Ready pod/arena-client \
  -n "${NAMESPACE}" --timeout=10s >/dev/null 2>&1; then

  set +e
  kubectl exec -n "${NAMESPACE}" arena-client -- \
    curl -fsS --max-time 5 http://arena-web-service
  rc=$?
  set -e

  echo
  echo "request_exit_code=${rc}"
else
  echo "arena-client is not Ready"
fi
