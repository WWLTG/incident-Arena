#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="incident-arena-08"
EXPECTED=$'application=arena-web\nenvironment=production\nstatus=running'

echo "===== Wait for healthy resources ====="
kubectl rollout status deployment/arena-web \
  -n "${NAMESPACE}" --timeout=90s

kubectl wait --for=condition=Ready pod/arena-client \
  -n "${NAMESPACE}" --timeout=60s

echo
echo "===== Resource status ====="
kubectl get deployment,pods -n "${NAMESPACE}"
kubectl get svc,endpointslices -n "${NAMESPACE}"

echo
echo "===== Validate Service endpoints ====="
ENDPOINTS="$(
  kubectl get endpointslices \
    -n "${NAMESPACE}" \
    -l kubernetes.io/service-name=arena-web-service \
    -o jsonpath='{range .items[*].endpoints[*]}{.addresses[0]}{"\n"}{end}'
)"

if [[ -z "${ENDPOINTS}" ]]; then
  echo "ERROR: arena-web-service has no endpoints"
  exit 1
fi

printf '%s\n' "${ENDPOINTS}"

echo
echo "===== End-to-end request ====="
ACTUAL="$(
  kubectl exec -n "${NAMESPACE}" arena-client -- \
    curl -fsS --max-time 5 http://arena-web-service
)"

printf '%s\n' "${ACTUAL}"

if [[ "${ACTUAL}" != "${EXPECTED}" ]]; then
  echo
  echo "ERROR: response does not match expected output"
  exit 1
fi

echo
echo "===== Incident Arena 08 verification passed ====="
