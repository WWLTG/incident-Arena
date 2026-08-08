#!/usr/bin/env bash
set -euo pipefail

APP_NS="incident-arena-07-app"
CLIENT_NS="incident-arena-07-client"
SERVICE_FQDN="arena-api-service.${APP_NS}.svc.cluster.local"
EXPECTED_MESSAGE="message=incident-arena-07"
EXPECTED_TOKEN="api_token=arena07-token"
EXPECTED_STATUS="status=running"

echo "===== Wait for healthy resources ====="
kubectl rollout status deployment/arena-api -n "$APP_NS" --timeout=120s
kubectl wait --for=condition=Ready pod/arena-client -n "$CLIENT_NS" --timeout=120s

echo
echo "===== Resource status ====="
kubectl get deployment,pods,service,endpointslice -n "$APP_NS" -o wide
kubectl get networkpolicy -n "$APP_NS"
kubectl get pod arena-client -n "$CLIENT_NS" -o wide

echo
echo "===== Deployment readiness ====="
ready_replicas="$(kubectl get deployment arena-api -n "$APP_NS" -o jsonpath='{.status.readyReplicas}')"
if [[ "$ready_replicas" != "1" ]]; then
  echo "Expected readyReplicas=1, got: ${ready_replicas:-0}" >&2
  exit 1
fi

echo "readyReplicas=$ready_replicas"

echo
echo "===== Service endpoints ====="
endpoint_count="$(kubectl get endpointslice -n "$APP_NS" -l kubernetes.io/service-name=arena-api-service -o jsonpath='{range .items[*].endpoints[*]}{.addresses[0]}{"\n"}{end}' | sed '/^$/d' | wc -l)"
if [[ "$endpoint_count" -lt 1 ]]; then
  echo "Expected at least one Service endpoint." >&2
  exit 1
fi

echo "endpoint_count=$endpoint_count"

echo
echo "===== End-to-end client request ====="
response="$(kubectl exec -n "$CLIENT_NS" arena-client -- wget -qO- -T 5 "http://${SERVICE_FQDN}")"
printf '%s\n' "$response"

grep -Fq "$EXPECTED_MESSAGE" <<<"$response"
grep -Fq "$EXPECTED_TOKEN" <<<"$response"
grep -Fq "$EXPECTED_STATUS" <<<"$response"

echo
echo "===== Final result ====="
echo "Incident Arena 07 verification passed."
