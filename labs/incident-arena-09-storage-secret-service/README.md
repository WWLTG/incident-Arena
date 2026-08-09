# Incident Arena 09 — Storage, Secret, and Service

Light troubleshooting lab with three intentional, logically ordered failures.

## Scenario

A small nginx application should:

- run in namespace `incident-arena-09`
- use a PersistentVolumeClaim
- read an application setting from a Secret
- be reachable through a ClusterIP Service
- be tested from a client Pod

The manifests are intentionally broken.

## Rules

- Investigate before changing anything.
- Fix one root cause at a time.
- Keep each investigation and each fix in a separate Git commit.
- Do not replace resources with a different design just to make the lab pass.
- Final verification must validate the complete scenario.

## Start

```bash
./scripts/apply-lab.sh
./scripts/baseline-tests.sh
```

## Suggested Git workflow

After adding this directory under the existing `incident-arena/labs/` repository:

```bash
git add labs/incident-arena-09-storage-secret-service
git commit -m "Add broken Incident Arena 09 lab"
```

Then continue with separate investigation and fix commits.

## Useful commands

```bash
kubectl get all -n incident-arena-09
kubectl get pvc -n incident-arena-09
kubectl get secret -n incident-arena-09
kubectl get endpointslice -n incident-arena-09
kubectl describe pod -n incident-arena-09
kubectl describe pvc -n incident-arena-09
kubectl describe deployment arena-web -n incident-arena-09
kubectl describe service arena-web-service -n incident-arena-09
kubectl get events -n incident-arena-09 --sort-by=.lastTimestamp
```

When you believe everything is fixed:

```bash
./scripts/final-verification.sh
```
