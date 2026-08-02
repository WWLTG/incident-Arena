# Investigation

Incident 1

Observed failure
The StatefulSet Pod remained Pending and could not be scheduled.

Evidence
The Pod event reported that PersistentVolumeClaim arena-store-dtaa was not found.
The existing PVC was named arena-store-data and remained in WaitForFirstConsumer state.

Root cause
The StatefulSet referenced the wrong PersistentVolumeClaim name because of a typo in claimName.

## Incident 2

### Observed failure

### Evidence

### Root cause

## Incident 3

### Observed failure

### Evidence

### Root cause
