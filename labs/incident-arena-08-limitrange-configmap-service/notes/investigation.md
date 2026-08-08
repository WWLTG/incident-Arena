# Incident Arena 08 
## Issue 1

Observed failure

The arena-web Deployment has no running Pod.
The ReplicaSet cannot create the requested Pod.

Evidence

Events report that the container requests a 512Mi memory limit,
while the namespace LimitRange allows a maximum of 256Mi.

Root cause

The Deployment memory limit exceeds the maximum memory limit
allowed by the namespace LimitRange.

Issue 2

Observed failure

The arena-web Pod is created but remains in CreateContainerConfigError.

Evidence

Pod events report that the key app-environment cannot be found
in the arena-web-config ConfigMap.

Root cause

The Deployment references the ConfigMap key app-environment,
but the ConfigMap contains the key environment.


## Issue 3

### Observed failure

### Evidence

### Root cause
