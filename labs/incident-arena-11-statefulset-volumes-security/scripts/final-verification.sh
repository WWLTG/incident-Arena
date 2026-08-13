#!/usr/bin/env bash
set -euo pipefail

NS="incident-arena-11"

fail() {
  echo "ERROR: $1" >&2
  exit 1
}

echo "===== Wait for healthy resources ====="
kubectl rollout status statefulset/arena-db -n "$NS" --timeout=180s
kubectl wait --for=condition=Ready pod/arena-client -n "$NS" --timeout=120s
echo

echo "===== Resource status ====="
kubectl get statefulset arena-db -n "$NS"
kubectl get pods -n "$NS" -o wide
kubectl get pvc -n "$NS"
kubectl get service arena-db-headless -n "$NS"
echo

echo "===== Validate replica count ====="
ready="$(kubectl get statefulset arena-db -n "$NS" -o jsonpath='{.status.readyReplicas}')"
[ "$ready" = "2" ] || fail "StatefulSet does not have 2 ready replicas (got: ${ready:-0})."
echo "readyReplicas=$ready"
echo

echo "===== Validate PVC binding ====="
for pvc in data-arena-db-0 data-arena-db-1; do
  phase="$(kubectl get pvc "$pvc" -n "$NS" -o jsonpath='{.status.phase}')"
  [ "$phase" = "Bound" ] || fail "PVC $pvc is not Bound (phase: ${phase:-unknown})."
  echo "$pvc phase=$phase"
done
echo

echo "===== Validate SecurityContext ====="
fs_group="$(kubectl get statefulset arena-db -n "$NS" -o jsonpath='{.spec.template.spec.securityContext.fsGroup}')"
[ -n "$fs_group" ] || fail "Pod securityContext.fsGroup is missing."
echo "fsGroup=$fs_group"
echo

echo "===== Validate readiness probe ====="
probe_port="$(kubectl get statefulset arena-db -n "$NS" -o jsonpath='{.spec.template.spec.containers[0].readinessProbe.httpGet.port}')"
[ "$probe_port" = "80" ] || fail "Readiness probe port must be 80 (got: ${probe_port:-unset})."
echo "readiness_port=$probe_port"
echo

echo "===== Validate headless Service ====="
cluster_ip="$(kubectl get service arena-db-headless -n "$NS" -o jsonpath='{.spec.clusterIP}')"
[ "$cluster_ip" = "None" ] || fail "Service arena-db-headless must be headless (clusterIP: None), got: ${cluster_ip:-unset}."
echo "clusterIP=$cluster_ip"
echo

echo "===== Validate per-pod DNS and content ====="
for i in 0 1; do
  pod="arena-db-$i"
  fqdn="$pod.arena-db-headless.$NS.svc.cluster.local"

  kubectl exec -n "$NS" arena-client -- nslookup "$fqdn" >/dev/null 2>&1 \
    || fail "DNS lookup failed for $fqdn."

  output="$(kubectl exec -n "$NS" arena-client -- wget -qO- --timeout=5 "http://$fqdn")"
  printf '%s\n' "$output"

  echo "$output" | grep -q "^pod=$pod$" || fail "Response from $fqdn does not report pod=$pod."
  echo "$output" | grep -q '^status=running$' || fail "Response from $fqdn is missing status=running."
  echo
done

echo "Incident Arena 11 verification passed."
