#!/usr/bin/env bash
set -euo pipefail

NS="incident-arena-09"

echo "===== Wait for healthy resources ====="
echo "Waiting for PVC to become Bound..."
for _ in $(seq 1 30); do
  phase="$(kubectl get pvc arena-web-data -n "$NS" -o jsonpath='{.status.phase}')"
  if [ "$phase" = "Bound" ]; then
    break
  fi
  sleep 2
done

test "$(kubectl get pvc arena-web-data -n "$NS" -o jsonpath='{.status.phase}')" = "Bound"

kubectl rollout status \
  deployment/arena-web \
  -n "$NS" \
  --timeout=90s

kubectl wait \
  --for=condition=Ready \
  pod/arena-client \
  -n "$NS" \
  --timeout=60s

echo
echo "===== Resource status ====="
kubectl get deployment,pod,pvc,service,endpointslice -n "$NS" -o wide

echo
echo "===== Secret-backed environment ====="
APP_MODE="$(
  kubectl exec -n "$NS" deployment/arena-web -- \
    printenv APP_MODE
)"

test "$APP_MODE" = "production"
echo "APP_MODE=$APP_MODE"

echo
echo "===== Service endpoint ====="
ENDPOINTS="$(
  kubectl get endpointslice \
    -n "$NS" \
    -l kubernetes.io/service-name=arena-web-service \
    -o jsonpath='{range .items[*].endpoints[*].addresses[*]}{.}{"\n"}{end}'
)"

test -n "$ENDPOINTS"
printf '%s\n' "$ENDPOINTS"

echo
echo "===== End-to-end client request ====="
RESPONSE="$(
  kubectl exec -n "$NS" arena-client -- \
    curl -fsS --max-time 5 http://arena-web-service
)"

printf '%s\n' "$RESPONSE" | grep -q "Welcome to nginx"

echo
echo "Incident Arena 09 verification PASSED."
