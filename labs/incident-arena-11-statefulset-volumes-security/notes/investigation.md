# Incident Arena 11 — Investigation

Observed failure: StatefulSet arena-db shows 0/2 ready, pod arena-db-0 stuck in Pending state.

Evidence: Pod events show FailedScheduling due to unbound PersistentVolumeClaim. PVC data-arena-db-0 stays Pending with event ProvisioningFailed, storageclass fast-ssd not found.

Root cause: volumeClaimTemplate in the StatefulSet references a nonexistent StorageClass (fast-ssd) instead of the cluster's actual default StorageClass.



## Failure 2

### Observed failure

### Evidence

### Root cause


## Failure 3

### Observed failure

### Evidence

### Root cause


## Failure 4

### Observed failure

### Evidence

### Root cause
