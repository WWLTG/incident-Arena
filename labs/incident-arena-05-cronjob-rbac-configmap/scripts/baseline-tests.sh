#!/usr/bin/env bash
set -u

NAMESPACE="incident-arena-05"
JOB_NAME="arena-report-manual"

printf '\n===== Workload configuration =====\n'
kubectl get cronjob arena-report -n "$NAMESPACE" -o wide
kubectl get serviceaccount,role,rolebinding,configmap -n "$NAMESPACE"

printf '\n===== Create manual Job from CronJob =====\n'
kubectl delete job "$JOB_NAME" \
  -n "$NAMESPACE" \
  --ignore-not-found=true \
  --wait=true >/dev/null 2>&1

kubectl create job "$JOB_NAME" \
  --from=cronjob/arena-report \
  -n "$NAMESPACE"

sleep 5

printf '\n===== Job and Pod status =====\n'
kubectl get job,pod -n "$NAMESPACE" -o wide

printf '\n===== Job details =====\n'
kubectl describe job "$JOB_NAME" -n "$NAMESPACE"

printf '\n===== Pod details =====\n'
POD_NAME="$(kubectl get pod -n "$NAMESPACE" \
  -l job-name="$JOB_NAME" \
  -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)"

if [ -n "$POD_NAME" ]; then
  kubectl describe pod "$POD_NAME" -n "$NAMESPACE"
  printf '\n===== Pod logs =====\n'
  kubectl logs "$POD_NAME" -n "$NAMESPACE" --all-containers=true 2>&1 || true
else
  echo "No Pod was created for $JOB_NAME"
fi

printf '\n===== Recent events =====\n'
kubectl get events -n "$NAMESPACE" \
  --sort-by=.metadata.creationTimestamp | tail -n 25
