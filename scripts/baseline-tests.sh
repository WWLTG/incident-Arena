#!/usr/bin/env bash
set -u

APP_NAMESPACE="incident-arena-03-app"
CLIENT_NAMESPACE="incident-arena-03-client"
CLIENT_POD="arena-client"
SERVICE_DNS="arena-api-service.${APP_NAMESPACE}.svc.cluster.local"
TRAEFIK_DNS="traefik.traefik.svc.cluster.local"

printf '\nDeployment and Pod status\n'
kubectl get deployment,pod \
  -n "$APP_NAMESPACE" \
  -l app=arena-api \
  -o wide

printf '\nService status\n'
kubectl get service arena-api-service \
  -n "$APP_NAMESPACE" \
  -o wide

printf '\nEndpointSlice status\n'
kubectl get endpointslice \
  -n "$APP_NAMESPACE" \
  -l kubernetes.io/service-name=arena-api-service \
  -o wide

printf '\nNetworkPolicy status\n'
kubectl get networkpolicy arena-api-ingress \
  -n "$APP_NAMESPACE"

printf '\nIngress status\n'
kubectl get ingress arena-api \
  -n "$APP_NAMESPACE" \
  -o wide

printf '\nDirect client request to Service\n'
kubectl exec -n "$CLIENT_NAMESPACE" "$CLIENT_POD" -- \
  curl --silent --show-error --fail-with-body \
  --connect-timeout 3 \
  --max-time 5 \
  "http://${SERVICE_DNS}/"
DIRECT_EXIT_CODE=$?
printf '\ndirect_request_exit_code=%s\n' "$DIRECT_EXIT_CODE"

printf '\nIngress request through Traefik\n'
if kubectl get service traefik -n traefik >/dev/null 2>&1; then
  kubectl exec -n "$CLIENT_NAMESPACE" "$CLIENT_POD" -- \
    curl --silent --show-error --fail-with-body \
    --connect-timeout 3 \
    --max-time 5 \
    --header 'Host: arena03.local' \
    "http://${TRAEFIK_DNS}/"
  INGRESS_EXIT_CODE=$?
  printf '\ningress_request_exit_code=%s\n' "$INGRESS_EXIT_CODE"
else
  printf '%s\n' 'Traefik Service not found in namespace traefik.'
  printf '%s\n' 'Ingress request skipped.'
fi
