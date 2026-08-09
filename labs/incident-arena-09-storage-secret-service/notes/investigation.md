# Investigation

 Observed failure

The arena-web Pod remains Pending and the PVC arena-web-data is not Bound.

Evidence

The PVC is Pending.

Events show:
storageclass.storage.k8s.io "arena-local" not found

The Pod cannot be scheduled because it has an unbound PersistentVolumeClaim.

Root cause

The PVC references a StorageClass named arena-local that does not exist in the cluster.

## Failure 2

### Observed failure

### Evidence

### Root cause


## Failure 3

### Observed failure

### Evidence

### Root cause
