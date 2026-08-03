#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="incident-arena-06"
DEPLOYMENT="arena-web"
SERVICE="arena-web-service"
HPA="arena-web-hpa"
CLIENT="arena-client"
LOAD_POD="arena-load"

SCALE_DOWN_TIMEOUT_SECONDS=300
SCALE_UP_TIMEOUT_SECONDS=180
READY_TIMEOUT_SECONDS=180

cleanup() {
  kubectl delete pod "${LOAD_POD}" \
    -n "${NAMESPACE}" \
    --ignore-not-found \
    --wait=false >/dev/null 2>&1 || true
}

trap cleanup EXIT

fail() {
  echo
  echo "verification_result=failed"
  echo "reason=$1"
  exit 1
}

section() {
  printf '\n===== %s =====\n' "$1"
}

section "Prerequisites"

kubectl get --raw /apis/metrics.k8s.io/v1beta1 >/dev/null 2>&1 \
  || fail "Metrics API is unavailable"

echo "metrics_api=available"

section "Wait for healthy resources"

kubectl rollout status deployment/"${DEPLOYMENT}" \
  -n "${NAMESPACE}" \
  --timeout=180s

kubectl wait \
  --for=condition=Ready \
  pod/"${CLIENT}" \
  -n "${NAMESPACE}" \
  --timeout=180s

section "Validate Service endpoints"

endpoint_count="$(
  kubectl get endpointslice \
    -n "${NAMESPACE}" \
    -l "kubernetes.io/service-name=${SERVICE}" \
    -o jsonpath='{range .items[*].endpoints[*]}{.addresses[0]}{"\n"}{end}' |
    sed '/^$/d' |
    wc -l
)"

endpoint_count="${endpoint_count//[[:space:]]/}"

if [[ ! "${endpoint_count}" =~ ^[0-9]+$ ]] ||
   (( endpoint_count < 1 )); then
  fail "Service has no EndpointSlice addresses"
fi

echo "endpoint_count=${endpoint_count}"

section "Validate end-to-end request"

response="$(
  kubectl exec -n "${NAMESPACE}" "${CLIENT}" -- \
    wget -q -T 5 -O- "http://${SERVICE}"
)"

printf 'service_response=%s\n' "${response}"

[[ -n "${response}" ]] \
  || fail "Service returned an empty response"

section "Validate HPA configuration"

target_name="$(
  kubectl get hpa "${HPA}" \
    -n "${NAMESPACE}" \
    -o jsonpath='{.spec.scaleTargetRef.name}'
)"

min_replicas="$(
  kubectl get hpa "${HPA}" \
    -n "${NAMESPACE}" \
    -o jsonpath='{.spec.minReplicas}'
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

[[ "${min_replicas}" =~ ^[0-9]+$ ]] \
  || fail "HPA minReplicas is not numeric"

[[ "${max_replicas}" =~ ^[0-9]+$ ]] \
  || fail "HPA maxReplicas is not numeric"

(( min_replicas == 1 )) \
  || fail "HPA minReplicas must be 1 for this verification"

(( max_replicas >= 2 )) \
  || fail "HPA maxReplicas is lower than 2"

[[ -n "${cpu_request}" ]] \
  || fail "The application container has no CPU request"

printf 'hpa_target=%s\n' "${target_name}"
printf 'hpa_min_replicas=%s\n' "${min_replicas}"
printf 'hpa_max_replicas=%s\n' "${max_replicas}"
printf 'container_cpu_request=%s\n' "${cpu_request}"

section "Return HPA to one replica"

kubectl delete pod "${LOAD_POD}" \
  -n "${NAMESPACE}" \
  --ignore-not-found \
  --wait=true

scaled_down=false
scale_down_deadline=$((SECONDS + SCALE_DOWN_TIMEOUT_SECONDS))

while (( SECONDS < scale_down_deadline )); do
  desired="$(
    kubectl get hpa "${HPA}" \
      -n "${NAMESPACE}" \
      -o jsonpath='{.status.desiredReplicas}' \
      2>/dev/null || true
  )"

  deployment_replicas="$(
    kubectl get deployment "${DEPLOYMENT}" \
      -n "${NAMESPACE}" \
      -o jsonpath='{.spec.replicas}' \
      2>/dev/null || true
  )"

  ready_replicas="$(
    kubectl get deployment "${DEPLOYMENT}" \
      -n "${NAMESPACE}" \
      -o jsonpath='{.status.readyReplicas}' \
      2>/dev/null || true
  )"

  metric="$(
    kubectl get hpa "${HPA}" \
      -n "${NAMESPACE}" \
      -o jsonpath='{.status.currentMetrics[0].resource.current.averageUtilization}' \
      2>/dev/null || true
  )"

  printf 'desired=%s deployment=%s ready=%s cpu_utilization=%s%%\n' \
    "${desired:-unknown}" \
    "${deployment_replicas:-unknown}" \
    "${ready_replicas:-0}" \
    "${metric:-unknown}"

  if [[ "${desired:-0}" == "1" ]] &&
     [[ "${deployment_replicas:-0}" == "1" ]] &&
     [[ "${ready_replicas:-0}" == "1" ]]; then
    scaled_down=true
    break
  fi

  sleep 5
done

if [[ "${scaled_down}" != true ]]; then
  kubectl get hpa "${HPA}" -n "${NAMESPACE}" || true
  kubectl describe hpa "${HPA}" -n "${NAMESPACE}" || true
  kubectl get deployment "${DEPLOYMENT}" -n "${NAMESPACE}" || true

  fail "HPA did not return to one Ready replica before the load test"
fi

echo "baseline_replicas=1"

section "Start bounded scaling load"

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

kubectl wait \
  --for=condition=Ready \
  pod/"${LOAD_POD}" \
  -n "${NAMESPACE}" \
  --timeout=60s

section "Wait for HPA scale-up request"

scaled=false
scale_up_deadline=$((SECONDS + SCALE_UP_TIMEOUT_SECONDS))

while (( SECONDS < scale_up_deadline )); do
  desired="$(
    kubectl get hpa "${HPA}" \
      -n "${NAMESPACE}" \
      -o jsonpath='{.status.desiredReplicas}' \
      2>/dev/null || true
  )"

  current="$(
    kubectl get hpa "${HPA}" \
      -n "${NAMESPACE}" \
      -o jsonpath='{.status.currentReplicas}' \
      2>/dev/null || true
  )"

  ready="$(
    kubectl get deployment "${DEPLOYMENT}" \
      -n "${NAMESPACE}" \
      -o jsonpath='{.status.readyReplicas}' \
      2>/dev/null || true
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

  if [[ "${desired:-0}" =~ ^[0-9]+$ ]] &&
     (( desired >= 2 )); then
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

section "Wait for scaled replicas and endpoints"

replicas_ready=false
ready_deadline=$((SECONDS + READY_TIMEOUT_SECONDS))

while (( SECONDS < ready_deadline )); do
  desired_replicas="$(
    kubectl get hpa "${HPA}" \
      -n "${NAMESPACE}" \
      -o jsonpath='{.status.desiredReplicas}' \
      2>/dev/null || true
  )"

  deployment_replicas="$(
    kubectl get deployment "${DEPLOYMENT}" \
      -n "${NAMESPACE}" \
      -o jsonpath='{.spec.replicas}' \
      2>/dev/null || true
  )"

  ready_replicas="$(
    kubectl get deployment "${DEPLOYMENT}" \
      -n "${NAMESPACE}" \
      -o jsonpath='{.status.readyReplicas}' \
      2>/dev/null || true
  )"

  scaled_endpoint_count="$(
    kubectl get endpointslice \
      -n "${NAMESPACE}" \
      -l "kubernetes.io/service-name=${SERVICE}" \
      -o jsonpath='{range .items[*].endpoints[*]}{.addresses[0]}{"\n"}{end}' \
      2>/dev/null |
      sed '/^$/d' |
      wc -l
  )"

  scaled_endpoint_count="${scaled_endpoint_count//[[:space:]]/}"

  printf 'desired=%s deployment=%s ready=%s endpoints=%s\n' \
    "${desired_replicas:-unknown}" \
    "${deployment_replicas:-unknown}" \
    "${ready_replicas:-0}" \
    "${scaled_endpoint_count:-0}"

  if [[ "${deployment_replicas:-0}" =~ ^[0-9]+$ ]] &&
     [[ "${ready_replicas:-0}" =~ ^[0-9]+$ ]] &&
     [[ "${scaled_endpoint_count:-0}" =~ ^[0-9]+$ ]] &&
     (( deployment_replicas >= 2 )) &&
     (( ready_replicas >= 2 )) &&
     (( scaled_endpoint_count >= 2 )); then
    replicas_ready=true
    break
  fi

  sleep 5
done

if [[ "${replicas_ready}" != true ]]; then
  kubectl get deployment,pods,endpointslice,hpa \
    -n "${NAMESPACE}" \
    -o wide || true

  fail "Scaled replicas or Service endpoints did not become Ready"
fi

printf 'desired_replicas=%s\n' "${desired_replicas}"
printf 'deployment_replicas=%s\n' "${deployment_replicas}"
printf 'ready_replicas=%s\n' "${ready_replicas}"
printf 'scaled_endpoint_count=%s\n' "${scaled_endpoint_count}"

section "Final resource status"

kubectl get deployment,pods,service,endpointslice,hpa \
  -n "${NAMESPACE}" \
  -o wide

section "Final end-to-end request"

final_response="$(
  kubectl exec -n "${NAMESPACE}" "${CLIENT}" -- \
    wget -q -T 5 -O- "http://${SERVICE}"
)"

printf 'final_service_response=%s\n' "${final_response}"

[[ -n "${final_response}" ]] \
  || fail "Final Service request returned an empty response"

printf '\nverification_result=passed\n'
