#!/usr/bin/env bash
set +e

NS="incident-arena-10"

echo "===== Deployment status ====="
kubectl get deployment arena-web -n "$NS"
echo

echo "===== Pods ====="
kubectl get pods -n "$NS" -o wide
echo

echo "===== ReplicaSet events ====="
rs="$(kubectl get rs -n "$NS" -l app=arena-web -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)"
if [ -n "$rs" ]; then
  kubectl describe rs "$rs" -n "$NS" | sed -n '/Events:/,$p'
else
  echo "No ReplicaSet found."
fi
echo

echo "===== ResourceQuota ====="
kubectl describe resourcequota arena-quota -n "$NS"
echo

echo "===== Service and EndpointSlice ====="
kubectl get service arena-web-service -n "$NS"
kubectl get endpointslice -n "$NS" -l kubernetes.io/service-name=arena-web-service
echo

echo "===== Ingress ====="
kubectl get ingress arena-web-ingress -n "$NS"
kubectl describe ingress arena-web-ingress -n "$NS"
echo

echo "===== Direct Service request ====="
kubectl exec -n "$NS" arena-client -- \
  wget -qO- --timeout=3 http://arena-web-service 2>&1
direct_status="$?"
echo
echo "direct_request_exit_code=$direct_status"
echo

echo "===== Ingress request through Traefik ====="
kubectl exec -n "$NS" arena-client -- \
  wget -qO- --timeout=3 \
  --header='Host: arena10.local' \
  http://traefik.traefik.svc.cluster.local 2>&1
ingress_status="$?"
echo
echo "ingress_request_exit_code=$ingress_status"

exit 0
