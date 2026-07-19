#!/usr/bin/env bash
set -euo pipefail

kubectl apply -f manifests/00-namespace.yaml
kubectl apply -f manifests/01-configmap.yaml
kubectl apply -f manifests/02-deployment.yaml
kubectl apply -f manifests/03-service.yaml
kubectl apply -f manifests/04-client.yaml

kubectl wait \
  --namespace incident-arena-01 \
  --for=condition=Available \
  deployment/arena-web \
  --timeout=90s

kubectl wait \
  --namespace incident-arena-01 \
  --for=condition=Ready \
  pod/arena-client \
  --timeout=90s

kubectl get all -n incident-arena-01
