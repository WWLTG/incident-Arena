#!/usr/bin/env bash
set -u

APP_NS="incident-arena-07-app"
CLIENT_NS="incident-arena-07-client"
SERVICE_FQDN="arena-api-service.${APP_NS}.svc.cluster.local"

echo "===== Deployment and Pod status ====="
kubectl get deployment,pods -n "$APP_NS" -o wide

echo
echo "===== Service and EndpointSlice status ====="
kubectl get service,endpointslice -n "$APP_NS"

echo
echo "===== Client status ====="
kubectl get pod arena-client -n "$CLIENT_NS" -o wide

echo
echo "===== Client request ====="
kubectl exec -n "$CLIENT_NS" arena-client -- \
  wget -qO- -T 3 "http://${SERVICE_FQDN}" 2>&1
rc=$?
echo
echo "request_exit_code=$rc"

exit 0
