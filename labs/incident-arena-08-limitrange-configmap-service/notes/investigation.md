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

## Issue 2

### Observed failure

### Evidence

### Root cause


## Issue 3

### Observed failure

### Evidence

### Root cause
