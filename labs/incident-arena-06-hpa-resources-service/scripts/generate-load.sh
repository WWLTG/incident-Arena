#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="incident-arena-06"
LOAD_POD="arena-load"

printf '\n===== Replace previous load Pod =====\n'
kubectl delete pod "${LOAD_POD}" \
  -n "${NAMESPACE}" \
  --ignore-not-found \
  --wait=true

printf '\n===== Start bounded load =====\n'
kubectl run "${LOAD_POD}" \
  -n "${NAMESPACE}" \
  --image=busybox:1.36.1 \
  --restart=Never \
  --labels=app=arena-load \
  --command -- \
  sh -c '
    i=0
    while [ "$i" -lt 9000 ]; do
      wget -q -T 2 -O- http://arena-web-service >/dev/null 2>&1 || true
      i=$((i + 1))
      sleep 0.01
    done
  '

printf '\n===== Observe HPA for up to 90 seconds =====\n'
for attempt in $(seq 1 18); do
  printf '\n--- observation %s/18 ---\n' "${attempt}"
  kubectl get hpa arena-web-hpa -n "${NAMESPACE}" 2>&1 || true
  kubectl get deployment arena-web -n "${NAMESPACE}" 2>&1 || true
  kubectl get pods -n "${NAMESPACE}" -l app=arena-web 2>&1 || true
  sleep 5
done

printf '\n===== HPA details =====\n'
kubectl describe hpa arena-web-hpa -n "${NAMESPACE}" 2>&1 || true

printf '\nThe load is bounded and the Pod can be removed with:\n'
printf '  kubectl delete pod %s -n %s --ignore-not-found\n' \
  "${LOAD_POD}" "${NAMESPACE}"
