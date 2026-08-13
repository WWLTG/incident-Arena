#!/usr/bin/env bash
set +e

NS="incident-arena-11"

echo "===== StatefulSet status ====="
kubectl get statefulset arena-db -n "$NS"
echo

echo "===== Pods ====="
kubectl get pods -n "$NS" -o wide
echo

echo "===== Pod events (arena-db-0) ====="
kubectl describe pod arena-db-0 -n "$NS" 2>/dev/null | sed -n '/Events:/,$p'
echo

echo "===== PersistentVolumeClaims ====="
kubectl get pvc -n "$NS"
echo

echo "===== PVC events (data-arena-db-0) ====="
kubectl describe pvc data-arena-db-0 -n "$NS" 2>/dev/null | sed -n '/Events:/,$p'
echo

echo "===== Headless Service ====="
kubectl get service arena-db-headless -n "$NS"
kubectl get service arena-db-headless -n "$NS" -o jsonpath='clusterIP={.spec.clusterIP}{"\n"}'
echo

echo "===== EndpointSlice ====="
kubectl get endpointslice -n "$NS" -l kubernetes.io/service-name=arena-db-headless
echo

echo "===== DNS lookup for arena-db-0 (via client) ====="
kubectl exec -n "$NS" arena-client -- \
  nslookup arena-db-0.arena-db-headless.$NS.svc.cluster.local 2>&1
dns_status="$?"
echo
echo "dns_lookup_exit_code=$dns_status"
echo

echo "===== Direct request to arena-db-0 (via client) ====="
kubectl exec -n "$NS" arena-client -- \
  wget -qO- --timeout=3 http://arena-db-0.arena-db-headless.$NS.svc.cluster.local 2>&1
direct_status="$?"
echo
echo "direct_request_exit_code=$direct_status"

exit 0
