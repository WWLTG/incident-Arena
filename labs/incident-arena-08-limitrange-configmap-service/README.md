# Incident Arena 08 — LimitRange, ConfigMap, Service

Light troubleshooting lab with **3 intentional errors**.

## Scenario

A small web application should:

1. Run successfully inside the `incident-arena-08` namespace.
2. Read its environment value from a ConfigMap.
3. Be reachable from the client through `arena-web-service`.
4. Return:

```text
application=arena-web
environment=production
status=running
```

## Rules

- Investigate before changing manifests.
- Keep each investigation and each fix in a separate Git commit.
- Do not add unrelated fixes.
- Final verification must validate the complete end-to-end path.

## Start

```bash
./scripts/apply-lab.sh
./scripts/baseline-tests.sh
```

## Useful commands

```bash
kubectl get all -n incident-arena-08
kubectl get events -n incident-arena-08 --sort-by=.metadata.creationTimestamp
kubectl describe deployment arena-web -n incident-arena-08
kubectl describe replicaset -n incident-arena-08
kubectl describe pod -n incident-arena-08
kubectl get limitrange -n incident-arena-08 -o yaml
kubectl get configmap -n incident-arena-08 -o yaml
kubectl get svc,endpointslices -n incident-arena-08
```

When you believe all issues are fixed:

```bash
./scripts/final-verification.sh
```
