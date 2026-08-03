#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="incident-arena-06"
DEPLOYMENT="arena-web"
SERVICE="arena-web-service"
HPA="arena-web-hpa"
CLIENT="arena-client"
LOAD_POD="arena-load"
SCALE_TIMEOUT_SECONDS=180

cleanup() {
  kubectl delete pod "${LOAD_POD}" \
    -n "${NAMESPACE}" \
    --ignore-not-found \
    --wait=false >/dev/null 2>&1 || true
}
trap cleanup EXIT

fail() {
  echo "verification_result=failed"
  echo "reason=$1"
  exit 1
}

printf '\n===== Prerequisites =====\n'
kubectl get --raw /apis/metrics.k8s.io/v1beta1 >/dev/null 2>&1 \
  || fail "Metrics API is unavailable"

printf 'metrics_api=available\n'

printf '\n===== Wait for healthy resources =====\n'
kubectl rollout status deployment/"${DEPLOYMENT}" \
  -n "${NAMESPACE}" \
  --timeout=180s

kubectl wait \
  --for=condition=Ready \
  pod/"${CLIENT}" \
  -n "${NAMESPACE}" \
  --timeout=180s

printf '\n===== Validate Service endpoints =====\n'
endpoint_count="$(
  kubectl get endpointslice \
    -n "${NAMESPACE}" \
    -l "kubernetes.io/service-name=${SERVICE}" \
    -o jsonpath='{range .items[*].endpoints[*]}{.addresses[0]}{"\n"}{end}' |
    sed '/^$/d' |
    wc -l
)"
endpoint_count="${endpoint_count//[[:space:]]/}"

if [[ -z "${endpoint_count}" || "${endpoint_count}" -lt 1 ]]; then
  fail "Service has no EndpointSlice addresses"
fi

echo "endpoint_count=${endpoint_count}"

printf '\n===== Validate end-to-end request =====\n'
response="$(
  kubectl exec -n "${NAMESPACE}" "${CLIENT}" -- \
    wget -q -T 5 -O- "http://${SERVICE}"
)"

printf 'service_response=%s\n' "${response}"
[[ -n "${response}" ]] || fail "Service returned an empty response"

printf '\n===== Validate HPA configuration =====\n'
target_name="$(
  kubectl get hpa "${HPA}" \
    -n "${NAMESPACE}" \
    -o jsonpath='{.spec.scaleTargetRef.name}'
)"
max_replicas="$(
  kubectl get hpa "${HPA}" \
    -n "${NAMESPACE}" \
    -o jsonpath='{.spec.maxReplicas}'
)"
cpu_request="$(
  kubectl get deployment "${DEPLOYMENT}" \
    -n "${NAMESPACE}" \
    -o jsonpath='{.spec.template.spec.containers[?(@.name=="arena-web")].resources.requests.cpu}'
)"

[[ "${target_name}" == "${DEPLOYMENT}" ]] \
  || fail "HPA scale target is not ${DEPLOYMENT}"

[[ "${max_replicas}" -ge 2 ]] \
  || fail "HPA maxReplicas is lower than 2"

[[ -n "${cpu_request}" ]] \
  || fail "The application container has no CPU request"

printf 'hpa_target=%s\n' "${target_name}"
printf 'hpa_max_replicas=%s\n' "${max_replicas}"
printf 'container_cpu_request=%s\n' "${cpu_request}"

printf '\n===== Start bounded scaling load =====\n'
kubectl delete pod "${LOAD_POD}" \
  -n "${NAMESPACE}" \
  --ignore-not-found \
  --wait=true

kubectl run "${LOAD_POD}" \
  -n "${NAMESPACE}" \
  --image=busybox:1.36.1 \
  --restart=Never \
  --labels=app=arena-load \
  --command -- \
  sh -c '
    i=0
    while [ "$i" -lt 12000 ]; do
      wget -q -T 2 -O- http://arena-web-service >/dev/null 2>&1 || true
      i=$((i + 1))
      sleep 0.01
    done
  '

printf '\n===== Wait for HPA scale-up =====\n'
scaled=false
deadline=$((SECONDS + SCALE_TIMEOUT_SECONDS))

while (( SECONDS < deadline )); do
  desired="$(
    kubectl get hpa "${HPA}" \
      -n "${NAMESPACE}" \
      -o jsonpath='{.status.desiredReplicas}' 2>/dev/null || true
  )"
  current="$(
    kubectl get hpa "${HPA}" \
      -n "${NAMESPACE}" \
      -o jsonpath='{.status.currentReplicas}' 2>/dev/null || true
  )"
  ready="$(
    kubectl get deployment "${DEPLOYMENT}" \
      -n "${NAMESPACE}" \
      -o jsonpath='{.status.readyReplicas}' 2>/dev/null || true
  )"
  metric="$(
    kubectl get hpa "${HPA}" \
      -n "${NAMESPACE}" \
      -o jsonpath='{.status.currentMetrics[0].resource.current.averageUtilization}' \
      2>/dev/null || true
  )"

  printf 'desired=%s current=%s ready=%s cpu_utilization=%s%%\n' \
    "${desired:-unknown}" \
    "${current:-unknown}" \
    "${ready:-0}" \
    "${metric:-unknown}"

  if [[ "${desired:-0}" =~ ^[0-9]+$ ]] && (( desired >= 2 )); then
    scaled=true
    break
  fi

  sleep 5
done

if [[ "${scaled}" != true ]]; then
  kubectl get hpa "${HPA}" -n "${NAMESPACE}" || true
  kubectl describe hpa "${HPA}" -n "${NAMESPACE}" || true
  fail "HPA did not request at least two replicas within the timeout"
fi

printf '\n===== Wait for scaled Deployment availability =====\n'
desired_replicas="$(
  kubectl get hpa "${HPA}" \
    -n "${NAMESPACE}" \
    -o jsonpath='{.status.desiredReplicas}'
)"

kubectl wait \
  --for=condition=Available \
  deployment/"${DEPLOYMENT}" \
  -n "${NAMESPACE}" \
  --timeout=180s

ready_replicas="$(
  kubectl get deployment "${DEPLOYMENT}" \
    -n "${NAMESPACE}" \
    -o jsonpath='{.status.readyReplicas}'
)"

if [[ ! "${ready_replicas:-0}" =~ ^[0-9]+$ ]] || \
   (( ready_replicas < 2 )); then
  fail "Fewer than two application replicas became Ready"
fi

printf 'desired_replicas=%s\n' "${desired_replicas}"
printf 'ready_replicas=%s\n' "${ready_replicas}"

printf '\n===== Final resource status =====\n'
kubectl get deployment,pods,service,endpointslice,hpa \
  -n "${NAMESPACE}" \
  -o wide

printf '\n===== Final end-to-end request =====\n'
kubectl exec -n "${NAMESPACE}" "${CLIENT}" -- \
  wget -q -T 5 -O- "http://${SERVICE}"
printf '\n'

printf '\nverification_result=passed\n'
