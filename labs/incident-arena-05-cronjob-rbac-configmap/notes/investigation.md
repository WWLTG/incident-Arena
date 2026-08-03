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

Issue 3
Observed failure
The reporting Pod remained forbidden from reading the ConfigMap after correcting the Role.

Evidence
The Pod used the arena-reporter ServiceAccount, but the RoleBinding subject referenced arena-report.

Root cause
The RoleBinding granted the Role to the wrong ServiceAccount.

---------------------------------------



## Issue 4

### Observed failure

### Evidence

### Root cause
