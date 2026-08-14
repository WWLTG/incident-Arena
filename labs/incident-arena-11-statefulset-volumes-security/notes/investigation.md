# Incident Arena 11 — Investigation

Observed failure: StatefulSet arena-db shows 0/2 ready, pod arena-db-0 stuck in Pending state.

Evidence: Pod events show FailedScheduling due to unbound PersistentVolumeClaim. PVC data-arena-db-0 stays Pending with event ProvisioningFailed, storageclass fast-ssd not found.

Root cause: volumeClaimTemplate in the StatefulSet references a nonexistent StorageClass (fast-ssd) instead of the cluster's actual default StorageClass.



Failure 2

Observed failure: Pod arena-db-0 is stuck in CrashLoopBackOff, container db restarting repeatedly.

Evidence: Events show the container is being created and started successfully but then backs off. PVC is now Bound with the standard StorageClass, so storage itself is no longer the issue.

Root cause: Pod securityContext sets runAsUser 1000 but does not set fsGroup, so the mounted volume ownership does not allow the container process to write to /usr/share/nginx/html, causing nginx to exit.


## Failure 3

### Observed failure

### Evidence

### Root cause


## Failure 4

### Observed failure

### Evidence

### Root cause
