#!/usr/bin/env bash
set -euo pipefail

NS="incident-arena-10"

fail() {
  echo "ERROR: $1" >&2
  exit 1
}

echo "===== Wait for healthy resources ====="
kubectl rollout status deployment/arena-web -n "$NS" --timeout=120s
kubectl wait --for=condition=Ready pod/arena-client -n "$NS" --timeout=120s
echo

echo "===== Resource status ====="
kubectl get resourcequota arena-quota -n "$NS"
kubectl get deployment arena-web -n "$NS"
kubectl get pods -n "$NS" -o wide
kubectl get service arena-web-service -n "$NS"
kubectl get endpointslice -n "$NS" -l kubernetes.io/service-name=arena-web-service
kubectl get ingress arena-web-ingress -n "$NS"
echo

echo "===== Validate Deployment resources ====="
req_cpu="$(kubectl get deployment arena-web -n "$NS" -o jsonpath='{.spec.template.spec.containers[0].resources.requests.cpu}')"
req_mem="$(kubectl get deployment arena-web -n "$NS" -o jsonpath='{.spec.template.spec.containers[0].resources.requests.memory}')"
lim_cpu="$(kubectl get deployment arena-web -n "$NS" -o jsonpath='{.spec.template.spec.containers[0].resources.limits.cpu}')"
lim_mem="$(kubectl get deployment arena-web -n "$NS" -o jsonpath='{.spec.template.spec.containers[0].resources.limits.memory}')"

[ -n "$req_cpu" ] || fail "CPU request is missing."
[ -n "$req_mem" ] || fail "Memory request is missing."
[ -n "$lim_cpu" ] || fail "CPU limit is missing."
[ -n "$lim_mem" ] || fail "Memory limit is missing."

echo "requests.cpu=$req_cpu"
echo "requests.memory=$req_mem"
echo "limits.cpu=$lim_cpu"
echo "limits.memory=$lim_mem"
echo

echo "===== Validate ConfigMap reference ====="
env_key="$(kubectl get deployment arena-web -n "$NS" -o jsonpath='{.spec.template.spec.containers[0].env[1].valueFrom.configMapKeyRef.key}')"
[ "$env_key" = "environment" ] || fail "APP_ENV does not reference ConfigMap key environment."
echo "APP_ENV key=$env_key"
echo

echo "===== Validate readiness probe ====="
probe_path="$(kubectl get deployment arena-web -n "$NS" -o jsonpath='{.spec.template.spec.containers[0].readinessProbe.httpGet.path}')"
[ "$probe_path" = "/" ] || fail "Readiness probe path must be /."
echo "readiness_path=$probe_path"
echo

echo "===== Validate Service endpoints ====="
endpoint_ips="$(kubectl get endpointslice -n "$NS" \
  -l kubernetes.io/service-name=arena-web-service \
  -o jsonpath='{range .items[*].endpoints[*]}{.addresses[0]}{" "}{end}')"
[ -n "$endpoint_ips" ] || fail "Service has no endpoints."
echo "endpoint_ips=$endpoint_ips"
echo

echo "===== Validate Ingress backend ====="
ingress_port="$(kubectl get ingress arena-web-ingress -n "$NS" \
  -o jsonpath='{.spec.rules[0].http.paths[0].backend.service.port.number}')"
[ "$ingress_port" = "80" ] || fail "Ingress backend port must be 80."
echo "ingress_backend_port=$ingress_port"
echo

echo "===== Direct Service request ====="
direct_output="$(kubectl exec -n "$NS" arena-client -- \
  wget -qO- --timeout=5 http://arena-web-service)"
printf '%s\n' "$direct_output"

echo "$direct_output" | grep -q '^application=arena-web$' || fail "Application value is incorrect."
echo "$direct_output" | grep -q '^environment=production$' || fail "Environment value is incorrect."
echo "$direct_output" | grep -q '^status=running$' || fail "Application status value is incorrect."
echo

echo "===== Ingress request through Traefik ====="
ingress_output="$(kubectl exec -n "$NS" arena-client -- \
  wget -qO- --timeout=5 \
  --header='Host: arena10.local' \
  http://traefik.traefik.svc.cluster.local)"
printf '%s\n' "$ingress_output"

echo "$ingress_output" | grep -q '^application=arena-web$' || fail "Ingress application value is incorrect."
echo "$ingress_output" | grep -q '^environment=production$' || fail "Ingress environment value is incorrect."
echo "$ingress_output" | grep -q '^status=running$' || fail "Ingress application status value is incorrect."

echo
echo "Incident Arena 10 verification passed."
