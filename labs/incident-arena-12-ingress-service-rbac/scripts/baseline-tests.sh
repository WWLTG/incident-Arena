#!/usr/bin/env bash
set +e

NS="incident-arena-12"

echo "=== Pods ==="
kubectl get pods -n "$NS" -o wide

echo ""
echo "=== Service endpoints ==="
kubectl get endpoints feature-flag-svc -n "$NS"

echo ""
echo "=== Ingress ==="
kubectl get ingress feature-flag-ingress -n "$NS"

echo ""
echo "=== Curl through Ingress (expect failure at this point) ==="
INGRESS_IP=$(kubectl get svc -n ingress-nginx ingress-nginx-controller -o jsonpath='{.spec.clusterIP}' 2>/dev/null)
if [ -n "$INGRESS_IP" ]; then
  curl -s -H "Host: flagapi.local" "http://$INGRESS_IP/flags.json" -m 5
else
  echo "Could not resolve ingress-nginx-controller service IP automatically."
  echo "Adjust INGRESS_IP in this script to match your controller's namespace/service name."
fi

echo ""
echo ""
echo "=== ServiceAccount used by the deployment ==="
kubectl get sa flag-reader -n "$NS"

echo ""
echo "=== RoleBinding subjects ==="
kubectl get rolebinding flag-reader-binding -n "$NS" -o jsonpath='{.subjects}'
echo ""
