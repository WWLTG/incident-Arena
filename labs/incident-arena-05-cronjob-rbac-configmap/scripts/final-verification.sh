#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="incident-arena-05"
JOB_NAME="arena-report-verification"
EXPECTED_OUTPUT="report_message=cluster-audit-ready"
SERVICE_ACCOUNT="system:serviceaccount:${NAMESPACE}:arena-reporter"

printf '\n===== RBAC verification =====\n'
kubectl auth can-i get configmaps \
  -n "$NAMESPACE" \
  --as="$SERVICE_ACCOUNT" | grep -qx yes

if kubectl auth can-i get secrets \
  -n "$NAMESPACE" \
  --as="$SERVICE_ACCOUNT" | grep -qx yes; then
  echo "Unexpected permission: ServiceAccount can read Secrets"
  exit 1
fi

echo "ServiceAccount can read ConfigMaps and cannot read Secrets"

printf '\n===== Create verification Job =====\n'
kubectl delete job "$JOB_NAME" \
  -n "$NAMESPACE" \
  --ignore-not-found=true \
  --wait=true >/dev/null

kubectl create job "$JOB_NAME" \
  --from=cronjob/arena-report \
  -n "$NAMESPACE"

kubectl wait \
  --for=condition=complete \
  job/"$JOB_NAME" \
  -n "$NAMESPACE" \
  --timeout=120s

printf '\n===== Verification output =====\n'
OUTPUT="$(kubectl logs job/"$JOB_NAME" -n "$NAMESPACE")"
echo "$OUTPUT"
grep -qx "$EXPECTED_OUTPUT" <<<"$OUTPUT"

printf '\n===== Final resource status =====\n'
kubectl get cronjob,job,pod,serviceaccount,role,rolebinding,configmap \
  -n "$NAMESPACE" -o wide

printf '\nIncident Arena 05 verification passed.\n'
