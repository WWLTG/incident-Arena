# Investigation

Issue 1
Observed failure

The manual Job could not create a Pod.

Evidence

The Job events reported that ServiceAccount arena-reporter-sa was not found. The existing ServiceAccount was named arena-reporter.

Root cause

The CronJob referenced a nonexistent ServiceAccount name.

---------------------------------------

Issue 2
Observed failure
The reporting container started but could not read the ConfigMap.

Evidence
The Pod logs returned Forbidden when the arena-reporter ServiceAccount attempted to get ConfigMaps. The Role granted get permission on Secrets instead of ConfigMaps.

Root cause
The Role targeted the wrong Kubernetes resource.


---------------------------------------


## Issue 3

### Observed failure

### Evidence

### Root cause

## Issue 4

### Observed failure

### Evidence

### Root cause
