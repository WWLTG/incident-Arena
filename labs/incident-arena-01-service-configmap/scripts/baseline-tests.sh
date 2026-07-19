#!/usr/bin/env bash
set -u

namespace=incident-arena-01
service_url=http://arena-web-service

printf '%s\n' 'Deployment status'
kubectl get deployment arena-web -n "$namespace"

printf '\n%s\n' 'Service and EndpointSlice status'
kubectl get service arena-web-service -n "$namespace"
kubectl get endpointslice \
  -n "$namespace" \
  -l kubernetes.io/service-name=arena-web-service \
  -o wide

printf '\n%s\n' 'Client request'
kubectl exec -n "$namespace" arena-client -- \
  wget -qO- --timeout=3 "$service_url"
request_exit_code=$?

printf '\nrequest_exit_code=%s\n' "$request_exit_code"

exit 0
