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

 Failure 2

Observed failure

The arena-web Pod is stuck in CreateContainerConfigError.

Evidence

Pod events show:

Error: couldn't find key app_mode in Secret incident-arena-09/arena-web-secret

Root cause

The Deployment references a Secret key that does not exist in arena-web-secret.


## Failure 3

### Observed failure

### Evidence

### Root cause
