#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
MANIFEST_DIR="${LAB_DIR}/manifests"
NAMESPACE="incident-arena-06"

printf '\n===== Apply Incident Arena 06 =====\n'
kubectl apply -f "${MANIFEST_DIR}"

printf '\n===== Wait for the workload and client =====\n'
kubectl rollout status deployment/arena-web \
  -n "${NAMESPACE}" \
  --timeout=180s

kubectl wait \
  --for=condition=Ready \
  pod/arena-client \
  -n "${NAMESPACE}" \
  --timeout=180s

printf '\n===== Metrics API prerequisite =====\n'
if kubectl get --raw /apis/metrics.k8s.io/v1beta1 >/dev/null 2>&1; then
  echo "metrics_api=available"
else
  echo "metrics_api=unavailable"
  echo "The lab can be applied, but HPA verification requires Metrics Server."
fi

printf '\nBroken lab applied.\n'
printf 'Next command:\n'
printf '  ./scripts/baseline-tests.sh\n'
