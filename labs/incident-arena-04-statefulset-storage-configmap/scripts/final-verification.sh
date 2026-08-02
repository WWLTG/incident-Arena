#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="incident-arena-04"
CLIENT_POD="arena-client"
POD="arena-store-0"

SERVICE_FQDN="arena-store.${NAMESPACE}.svc.cluster.local"
POD_FQDN="${POD}.arena-store.${NAMESPACE}.svc.cluster.local"

section() {
  printf '\n===== %s =====\n' "$1"
}

fail() {
  echo "Verification failed: $*" >&2
  exit 1
}

section "Wait for healthy resources"

kubectl wait \
  --for=jsonpath='{.status.phase}'=Bound \
  pvc/arena-store-data \
  -n "$NAMESPACE" \
  --timeout=120s

kubectl rollout status \
  statefulset/arena-store \
  -n "$NAMESPACE" \
  --timeout=180s

kubectl wait \
  --for=condition=Ready \
  pod/"$CLIENT_POD" \
  -n "$NAMESPACE" \
  --timeout=60s

section "Resource status"

kubectl get storageclass incident-arena-04-local

kubectl get pvc,statefulset,pod,service,endpointslice \
  -n "$NAMESPACE" \
  -o wide

section "Endpoint verification"

endpoint_count=$(
  kubectl get endpointslice \
    -n "$NAMESPACE" \
    -l kubernetes.io/service-name=arena-store \
    -o jsonpath='{range .items[*].endpoints[?(@.conditions.ready==true)]}{.addresses[0]}{"\n"}{end}' |
    sed '/^$/d' |
    wc -l
)

[ "$endpoint_count" -ge 1 ] || \
  fail "the headless Service has no ready endpoint"

echo "Ready endpoint count: $endpoint_count"

section "Service DNS and HTTP"

kubectl exec "$CLIENT_POD" -n "$NAMESPACE" -- \
  nslookup "$SERVICE_FQDN"

kubectl exec "$CLIENT_POD" -n "$NAMESPACE" -- \
  nslookup "$POD_FQDN"

response=$(
  kubectl exec "$CLIENT_POD" -n "$NAMESPACE" -- \
    wget -qO- -T 5 "http://${SERVICE_FQDN}"
)

printf '%s\n' "$response"

printf '%s\n' "$response" |
  grep -qx 'application=arena-store' ||
  fail "application marker is missing"

printf '%s\n' "$response" |
  grep -qx 'environment=production' ||
  fail "environment marker is missing"

printf '%s\n' "$response" |
  grep -qx 'status=running' ||
  fail "status marker is missing"

printf '%s\n' "$response" |
  grep -q '^created_at=' ||
  fail "persistent creation marker is missing"

printf '%s\n' "$response" |
  grep -qx 'pod=arena-store-0' ||
  fail "StatefulSet Pod identity marker is missing"

section "Persistent data before Pod recreation"

before=$(
  kubectl exec "$POD" -n "$NAMESPACE" -c web -- \
    cat /usr/share/nginx/html/created-at.txt
)

old_uid=$(
  kubectl get pod "$POD" \
    -n "$NAMESPACE" \
    -o jsonpath='{.metadata.uid}'
)

echo "created-at before recreation: $before"
echo "old Pod UID: $old_uid"

kubectl delete pod "$POD" \
  -n "$NAMESPACE" \
  --wait=false >/dev/null

new_uid=""
ready=""

for _ in $(seq 1 90); do
  new_uid=$(
    kubectl get pod "$POD" \
      -n "$NAMESPACE" \
      -o jsonpath='{.metadata.uid}' \
      2>/dev/null || true
  )

  ready=$(
    kubectl get pod "$POD" \
      -n "$NAMESPACE" \
      -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}' \
      2>/dev/null || true
  )

  if [ -n "$new_uid" ] &&
     [ "$new_uid" != "$old_uid" ] &&
     [ "$ready" = "True" ]; then
    break
  fi

  sleep 2
done

[ -n "$new_uid" ] || \
  fail "the StatefulSet Pod was not recreated"

[ "$new_uid" != "$old_uid" ] || \
  fail "the Pod UID did not change"

[ "$ready" = "True" ] || \
  fail "the recreated Pod did not become Ready"

after=$(
  kubectl exec "$POD" -n "$NAMESPACE" -c web -- \
    cat /usr/share/nginx/html/created-at.txt
)

echo "new Pod UID: $new_uid"
echo "created-at after recreation:  $after"

[ "$before" = "$after" ] || \
  fail "persistent marker changed after Pod recreation"

section "DNS and HTTP after Pod recreation"

kubectl exec "$CLIENT_POD" -n "$NAMESPACE" -- \
  nslookup "$POD_FQDN"

final_response=$(
  kubectl exec "$CLIENT_POD" -n "$NAMESPACE" -- \
    wget -qO- -T 5 "http://${SERVICE_FQDN}"
)

printf '%s\n' "$final_response"

printf '%s\n' "$final_response" |
  grep -qx 'application=arena-store' ||
  fail "application marker is missing after Pod recreation"

printf '%s\n' "$final_response" |
  grep -qx 'environment=production' ||
  fail "environment marker is missing after Pod recreation"

printf '%s\n' "$final_response" |
  grep -q "^created_at=${before}$" ||
  fail "persistent marker is missing after Pod recreation"

printf '%s\n' "$final_response" |
  grep -qx 'pod=arena-store-0' ||
  fail "StatefulSet Pod identity marker is missing after recreation"

printf '\nAll Incident Arena 04 verification checks passed.\n'
