#!/usr/bin/env bash
set -u

NAMESPACE="incident-arena-06"
SERVICE_URL="http://arena-web-service"

section() {
  printf '\n===== %s =====\n' "$1"
}

section "Metrics API"
if kubectl get --raw /apis/metrics.k8s.io/v1beta1 >/dev/null 2>&1; then
  echo "metrics_api=available"
  kubectl top pods -n "${NAMESPACE}" 2>&1 || true
else
  echo "metrics_api=unavailable"
fi

section "Deployment and Pods"
kubectl get deployment,pods -n "${NAMESPACE}" -o wide

section "Service and EndpointSlices"
kubectl get service,endpointslice -n "${NAMESPACE}" -o wide

section "HorizontalPodAutoscaler"
kubectl get hpa -n "${NAMESPACE}"
kubectl describe hpa arena-web-hpa -n "${NAMESPACE}"

section "Client request"
set +e
kubectl exec -n "${NAMESPACE}" arena-client -- \
  wget -q -T 5 -O- "${SERVICE_URL}"
request_exit_code=$?
set -e
printf '\nrequest_exit_code=%s\n' "${request_exit_code}"

section "Recent events"
kubectl get events \
  -n "${NAMESPACE}" \
  --sort-by=.metadata.creationTimestamp
