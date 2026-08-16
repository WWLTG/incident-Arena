#!/usr/bin/env bash
set -euo pipefail

NS="incident-arena-12"

echo "Verifying RoleBinding subject..."
SUBJECT=$(kubectl get rolebinding flag-reader-binding -n "$NS" -o jsonpath='{.subjects[0].name}')
if [ "$SUBJECT" != "flag-reader" ]; then
  echo "FAIL: RoleBinding subject is '$SUBJECT', expected 'flag-reader'"
  exit 1
fi
echo "OK: RoleBinding subject correct"

echo "Verifying Service selector..."
SELECTOR=$(kubectl get svc feature-flag-svc -n "$NS" -o jsonpath='{.spec.selector.app}')
if [ "$SELECTOR" != "flag-api" ]; then
  echo "FAIL: Service selector is 'app=$SELECTOR', expected 'app=flag-api'"
  exit 1
fi
echo "OK: Service selector correct"

echo "Verifying Ingress backend port..."
PORT=$(kubectl get ingress feature-flag-ingress -n "$NS" -o jsonpath='{.spec.rules[0].http.paths[0].backend.service.port.number}')
if [ "$PORT" != "80" ]; then
  echo "FAIL: Ingress backend port is '$PORT', expected '80'"
  exit 1
fi
echo "OK: Ingress backend port correct"

echo "Verifying pods are Ready..."
READY=$(kubectl get pods -n "$NS" -l app=flag-api -o jsonpath='{.items[*].status.containerStatuses[0].ready}')
for r in $READY; do
  if [ "$r" != "true" ]; then
    echo "FAIL: not all pods are Ready"
    exit 1
  fi
done
echo "OK: All pods Ready"

echo ""
echo "All checks passed. Lab 12 fully fixed."
