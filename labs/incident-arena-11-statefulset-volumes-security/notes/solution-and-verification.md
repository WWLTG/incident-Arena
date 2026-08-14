# Incident Arena 11 — Solution and Verification

## Changes

1. Fixed the volumeClaimTemplate storageClassName from the nonexistent `fast-ssd` to the cluster's actual default StorageClass `standard`, allowing the PVC to bind and the pod to be scheduled.
2. Added `fsGroup: 1000` to the pod securityContext and added `emptyDir` volumes for `/var/cache/nginx` and `/var/run`, fixing the permission denied errors that caused CrashLoopBackOff.
3. Fixed the readinessProbe port from `8080` to `80`, allowing arena-db-0 to become Ready and, due to OrderedReady, allowing arena-db-1 to be created.
4. Added `clusterIP: None` to the arena-db-headless Service, making it a true headless Service so DNS queries against the service name return all pod addresses instead of a single ClusterIP.

## Verification

Final command:

```bash
./scripts/final-verification.sh
```

Result:

```text
Incident Arena 11 verification passed.
```
